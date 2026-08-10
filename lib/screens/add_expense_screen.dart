import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/server_provider.dart';
import '../providers/auth_provider.dart';
import '../services/expense_service.dart';
import '../models/server_model.dart';
import 'package:dhanwiser_fixed/theme/text_styles.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

class AddExpenseScreen extends StatefulWidget {
  final int? serverId;

  const AddExpenseScreen({super.key, this.serverId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  String _selectedCategory = 'Food';
  String _splitType = 'equally';
  int? _selectedServerId;
  int? _selectedChannelId;
  int? _paidByUserId;
  bool _isSaving = false;

  // Per-member custom amounts & selected participants
  final Map<int, TextEditingController> _customAmountControllers = {};
  final Set<int> _selectedUserIds = {};

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant_rounded},
    {'name': 'Transport', 'icon': Icons.directions_car_rounded},
    {'name': 'Rent', 'icon': Icons.home_rounded},
    {'name': 'Utilities', 'icon': Icons.lightbulb_rounded},
    {'name': 'Groceries', 'icon': Icons.shopping_cart_rounded},
    {'name': 'Entertainment', 'icon': Icons.movie_rounded},
    {'name': 'Other', 'icon': Icons.inventory_2_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _selectedServerId = widget.serverId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serverProv = Provider.of<ServerProvider>(context, listen: false);
      if (_selectedServerId == null) {
        serverProv.fetchServers().then((_) {
          if (!mounted) return;
          final prov = Provider.of<ServerProvider>(context, listen: false);
          if (prov.servers.isNotEmpty) {
            _onServerSelected(prov.servers.first.id);
          }
        });
      } else {
        serverProv.fetchServerDetails(_selectedServerId!).then((_) {
          // Auto-select the first channel
          if (!mounted) return;
          final prov = Provider.of<ServerProvider>(context, listen: false);
          if (prov.channels.isNotEmpty) {
            setState(() => _selectedChannelId = prov.channels.first.id);
          }
        });
      }
      // Default payer = current user
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _paidByUserId = auth.currentUser?.id;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    for (final c in _customAmountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<ServerMember> _getMembers() {
    final serverProv = Provider.of<ServerProvider>(context, listen: false);
    return serverProv.currentServerDetail?.members ?? [];
  }

  List<Map<String, dynamic>> _buildParticipants() {
    final members = _getMembers();
    if (members.isEmpty) return [];

    final activeMembers =
        members.where((m) => _selectedUserIds.contains(m.userId)).toList();
    if (activeMembers.isEmpty) return [];

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) return [];

    if (_splitType == 'equally') {
      final rounded =
          double.parse((amount / activeMembers.length).toStringAsFixed(2));
      // Last active person absorbs rounding difference so sum == amount exactly
      final remainder = double.parse(
          (amount - rounded * (activeMembers.length - 1)).toStringAsFixed(2));
      return List.generate(activeMembers.length, (i) {
        final m = activeMembers[i];
        final owed = (i == activeMembers.length - 1) ? remainder : rounded;
        return {
          'userId': m.userId,
          'amountPaid': m.userId == _paidByUserId ? amount : 0.0,
          'amountOwed': owed,
        };
      });
    } else {
      // Custom split: only selected members
      return activeMembers.map((m) {
        final controller = _customAmountControllers[m.userId];
        final owed = double.tryParse(controller?.text.trim() ?? '0') ?? 0;
        return {
          'userId': m.userId,
          'amountPaid': m.userId == _paidByUserId ? amount : 0.0,
          'amountOwed': owed,
        };
      }).toList();
    }
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amountController.text.trim());
    final title = _noteController.text.trim();

    if (amount == null || amount <= 0) {
      _showError('Enter a valid amount');
      return;
    }
    if (title.isEmpty) {
      _showError('Describe the expense');
      return;
    }
    if (_selectedServerId == null) {
      _showError('Select a group');
      return;
    }

    // If members not yet loaded, fetch on-demand
    var members = _getMembers();
    if (members.isEmpty) {
      try {
        final serverProv = Provider.of<ServerProvider>(context, listen: false);
        await serverProv.fetchServerDetails(_selectedServerId!);
        members = _getMembers();
      } catch (_) {}
    }
    if (members.isEmpty) {
      _showError('No members found in this group');
      return;
    }
    if (_selectedUserIds.isEmpty) {
      _showError('Select at least 1 person to split with');
      return;
    }

    // Validate custom split sums to total
    if (_splitType == 'custom') {
      double sum = 0;
      for (final m in members) {
        final controller = _customAmountControllers[m.userId];
        sum += double.tryParse(controller?.text.trim() ?? '0') ?? 0;
      }
      if ((sum - amount).abs() > 0.01) {
        _showError(
            'Custom amounts (₹${sum.toStringAsFixed(2)}) must equal total (₹${amount.toStringAsFixed(2)})');
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      // Always fetch channel freshly — avoids timing race condition.
      // The backend auto-creates a "General" channel if none exists.
      int channelId;
      if (_selectedChannelId != null) {
        channelId = _selectedChannelId!;
      } else {
        if (!mounted) return;
        final serverProv = Provider.of<ServerProvider>(context, listen: false);
        var channels = serverProv.channels;
        if (channels.isEmpty) {
          // Fetch fresh from server (backend will auto-create General channel)
          await serverProv.fetchServerDetails(_selectedServerId!);
          if (!mounted) return;
          channels = serverProv.channels;
        }
        if (channels.isEmpty) {
          _showError('Could not load channels. Please try again.');
          return;
        }
        channelId = channels.first.id;
        setState(() => _selectedChannelId = channelId);
      }

      final participants = _buildParticipants();

      await ExpenseService.addExpense(
        channelId: channelId,
        title: title,
        totalAmount: amount,
        expenseDate: DateTime.now().toIso8601String(),
        participants: participants,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ₹${amount.toStringAsFixed(0)} to $title'),
            backgroundColor: DhanWiserColors.of(context).mint,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showError('Failed: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: DhanWiserColors.of(context).coral,
      ),
    );
  }

  void _onServerSelected(int serverId) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _selectedServerId = serverId;
      _selectedChannelId = null; // reset channel when switching servers
      _paidByUserId = auth.currentUser?.id; // reset payer to current user
      _selectedUserIds.clear();
    });
    Provider.of<ServerProvider>(context, listen: false)
        .fetchServerDetails(serverId)
        .then((_) {
      // Auto-select the first channel once server details are loaded
      if (!mounted) return;
      final serverProv = Provider.of<ServerProvider>(context, listen: false);
      if (serverProv.channels.isNotEmpty) {
        setState(() => _selectedChannelId = serverProv.channels.first.id);
      }
    });
  }

  void _initCustomControllers(List<ServerMember> members) {
    if (_selectedUserIds.isEmpty && members.isNotEmpty) {
      _selectedUserIds.addAll(members.map((m) => m.userId));
    }
    for (final m in members) {
      if (!_customAmountControllers.containsKey(m.userId)) {
        _customAmountControllers[m.userId] = TextEditingController();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhanWiserColors.of(context).background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: PremiumIconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: DhanWiserColors.of(context).textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Expense',
          style: DhanWiserTextStyles.buttonLarge(context)
              .copyWith(color: DhanWiserColors.of(context).textPrimary),
        ),
        centerTitle: true,
        actions: [
          PremiumIconButton(
            icon: Icon(Icons.more_vert_rounded,
                color: DhanWiserColors.of(context).textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Amount Input Hero (Tactile Obsidian Header) ──
          GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(_amountFocusNode),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    'TOTAL AMOUNT',
                    style: DhanWiserTextStyles.overline(context).copyWith(
                        letterSpacing: 1.0,
                        color: DhanWiserColors.of(context).textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall!
                            .copyWith(
                                color: DhanWiserColors.of(context).primary,
                                fontFeatures: const [
                              FontFeature.tabularFigures()
                            ]),
                      ),
                      const SizedBox(width: 8),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          focusNode: _amountFocusNode,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textAlign: TextAlign.center,
                          onChanged: (_) => setState(() {}),
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                  color: DhanWiserColors.of(context).textPrimary,
                                  height: 1.0,
                                  fontFeatures: const [
                                FontFeature.tabularFigures()
                              ]),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                    color: DhanWiserColors.of(context).textDisabled
                                        .withValues(alpha: 0.5),
                                    height: 1.0,
                                    fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ]),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Form Sheet Container ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: DhanWiserColors.of(context).surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                    color:
                        DhanWiserColors.of(context).surfaceBright.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: DhanWiserColors.of(context).secondaryContainer
                        .withValues(alpha: 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, -8),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Expense Title
                      _buildSectionTitle('EXPENSE TITLE'),
                      SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: DhanWiserColors.of(context).background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded,
                                color: DhanWiserColors.of(context).textSecondary, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _noteController,
                                style: DhanWiserTextStyles.bodyRegular(context)
                                    .copyWith(
                                        color: DhanWiserColors.of(context).textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Friday Dinner',
                                  hintStyle:
                                      DhanWiserTextStyles.bodyRegular(context)
                                          .copyWith(
                                              color:
                                                  DhanWiserColors.of(context).textDisabled),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Category
                      _buildSectionTitle('CATEGORY'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final isSelected = _selectedCategory == cat['name'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _selectedCategory = cat['name']!),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? DhanWiserColors.of(context).secondaryContainer
                                                .withValues(alpha: 0.2)
                                            : DhanWiserColors.of(context).background,
                                        border: Border.all(
                                          color: isSelected
                                              ? DhanWiserColors.of(context).secondaryContainer
                                                  .withValues(alpha: 0.5)
                                              : DhanWiserColors.of(context).surfaceBright
                                                  .withValues(alpha: 0.3),
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: DhanWiserColors.of(context).secondaryContainer
                                                      .withValues(alpha: 0.15),
                                                  blurRadius: 15,
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Icon(
                                        cat['icon'],
                                        color: isSelected
                                            ? DhanWiserColors.of(context).secondaryFixed
                                            : DhanWiserColors.of(context).textSecondary,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      cat['name']!,
                                      style:
                                          DhanWiserTextStyles.caption(context)
                                              .copyWith(
                                                  color: isSelected
                                                      ? DhanWiserColors.of(context).textPrimary
                                                      : DhanWiserColors.of(context).textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 24),

                      // Split Engine
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: DhanWiserColors.of(context).background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: DhanWiserColors.of(context).surfaceBright
                                  .withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Group Selector (Optional logic if not selected)
                            if (_selectedServerId == null) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Group',
                                      style: DhanWiserTextStyles.bodyRegular(
                                              context)
                                          .copyWith(
                                              color: DhanWiserColors.of(context).textSecondary)),
                                  Consumer<ServerProvider>(
                                    builder: (context, serverProv, _) {
                                      if (serverProv.servers.isEmpty) {
                                        return Text('No groups',
                                            style: DhanWiserTextStyles.caption(
                                                    context)
                                                .copyWith(
                                                    color: DhanWiserColors.of(context).textSecondary));
                                      }
                                      return DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: _selectedServerId,
                                          dropdownColor:
                                              DhanWiserColors.of(context).surface,
                                          hint: Text('Select group',
                                              style:
                                                  DhanWiserTextStyles.caption(
                                                          context)
                                                      .copyWith(
                                                          color: DhanWiserColors.of(context).textPrimary)),
                                          icon: Icon(Icons.expand_more_rounded,
                                              color:
                                                  DhanWiserColors.of(context).textDisabled,
                                              size: 16),
                                          style: DhanWiserTextStyles.caption(
                                                  context)
                                              .copyWith(
                                                  color: DhanWiserColors.of(context).textPrimary),
                                          onChanged: (val) {
                                            if (val != null)
                                              _onServerSelected(val);
                                          },
                                          items: serverProv.servers.map((s) {
                                            return DropdownMenuItem(
                                                value: s.id,
                                                child: Text(s.name));
                                          }).toList(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Divider(
                                  color: DhanWiserColors.of(context).surfaceBright,
                                  height: 24),
                            ],

                            // Paid by
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Paid by',
                                    style:
                                        DhanWiserTextStyles.bodyRegular(context)
                                            .copyWith(
                                                color: DhanWiserColors.of(context).textSecondary)),
                                Consumer<ServerProvider>(
                                  builder: (context, serverProv, _) {
                                    final members = serverProv
                                            .currentServerDetail?.members ??
                                        [];
                                    if (members.isEmpty)
                                      return const SizedBox.shrink();

                                    final auth = Provider.of<AuthProvider>(
                                        context,
                                        listen: false);
                                    final currentUserId = auth.currentUser?.id;

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: DhanWiserColors.of(context).surface,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: DhanWiserColors.of(context).surfaceBright
                                                .withValues(alpha: 0.2)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: members.any((m) =>
                                                  m.userId == _paidByUserId)
                                              ? _paidByUserId
                                              : (members.isNotEmpty
                                                  ? members.first.userId
                                                  : null),
                                          dropdownColor:
                                              DhanWiserColors.of(context).surface,
                                          icon: Icon(Icons.expand_more_rounded,
                                              color:
                                                  DhanWiserColors.of(context).textDisabled,
                                              size: 16),
                                          style: DhanWiserTextStyles.caption(
                                                  context)
                                              .copyWith(
                                                  color: DhanWiserColors.of(context).textPrimary),
                                          onChanged: (val) => setState(
                                              () => _paidByUserId = val),
                                          items: members.map((m) {
                                            return DropdownMenuItem(
                                              value: m.userId,
                                              child: Text(m.userId ==
                                                      currentUserId
                                                  ? 'You'
                                                  : m.fullName.split(' ')[0]),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Divider(
                                color: DhanWiserColors.of(context).surfaceBright
                                    .withValues(alpha: 0.2),
                                height: 32),

                            // Split with Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Split with (${_selectedUserIds.length}/${_getMembers().length})',
                                  style: DhanWiserTextStyles.bodyRegular(
                                          context)
                                      .copyWith(
                                          color: DhanWiserColors.of(context).textSecondary),
                                ),
                                PremiumTextButton(
                                  onPressed: () {
                                    final members = _getMembers();
                                    setState(() {
                                      if (_selectedUserIds.length ==
                                          members.length) {
                                        _selectedUserIds.clear();
                                        if (_paidByUserId != null)
                                          _selectedUserIds.add(_paidByUserId!);
                                      } else {
                                        _selectedUserIds.addAll(
                                            members.map((m) => m.userId));
                                      }
                                    });
                                  },
                                  child: Text(
                                    _selectedUserIds.length ==
                                            _getMembers().length
                                        ? 'Select None'
                                        : 'Select All',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            color:
                                                DhanWiserColors.of(context).tertiaryFixed),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),

                            // Segmented Control
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: DhanWiserColors.of(context).surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: DhanWiserColors.of(context).surfaceBright
                                        .withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(
                                          () => _splitType = 'equally'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _splitType == 'equally'
                                              ? DhanWiserColors.of(context).tertiaryFixed
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Equally',
                                          textAlign: TextAlign.center,
                                          style: DhanWiserTextStyles.overline(
                                                  context)
                                              .copyWith(
                                                  color: _splitType == 'equally'
                                                      ? DhanWiserColors.of(context).background
                                                      : DhanWiserColors.of(context).textSecondary),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _splitType = 'custom'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _splitType == 'custom'
                                              ? DhanWiserColors.of(context).tertiaryFixed
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Manually',
                                          textAlign: TextAlign.center,
                                          style: DhanWiserTextStyles.overline(
                                                  context)
                                              .copyWith(
                                                  color: _splitType == 'custom'
                                                      ? DhanWiserColors.of(context).background
                                                      : DhanWiserColors.of(context).textSecondary),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),

                            // Split Preview Rows
                            if (_selectedServerId != null)
                              Consumer<ServerProvider>(
                                builder: (context, serverProv, _) {
                                  final members =
                                      serverProv.currentServerDetail?.members ??
                                          [];
                                  if (members.isEmpty)
                                    return const SizedBox.shrink();

                                  _initCustomControllers(members);
                                  final activeMembers = members
                                      .where((m) =>
                                          _selectedUserIds.contains(m.userId))
                                      .toList();
                                  final amount = double.tryParse(
                                          _amountController.text.trim()) ??
                                      0;
                                  final perPerson = activeMembers.isNotEmpty
                                      ? amount / activeMembers.length
                                      : 0.0;

                                  double sumCustom = 0;
                                  if (_splitType == 'custom') {
                                    for (final m in activeMembers) {
                                      sumCustom += double.tryParse(
                                              _customAmountControllers[m.userId]
                                                      ?.text
                                                      .trim() ??
                                                  '0') ??
                                          0;
                                    }
                                  }
                                  final remaining = amount - sumCustom;

                                  return Column(
                                    children: [
                                      ...members.map((m) =>
                                          _buildSplitPreviewRow(m, perPerson)),
                                      if (_splitType == 'custom') ...[
                                        const SizedBox(height: 12),
                                        Divider(
                                            color: DhanWiserColors.of(context).surfaceBright
                                                .withValues(alpha: 0.1),
                                            height: 1),
                                        SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Remaining to split',
                                                style: DhanWiserTextStyles
                                                        .caption(context)
                                                    .copyWith(
                                                        color: DhanWiserColors.of(context).textSecondary)),
                                            Text(
                                              '₹${remaining.toStringAsFixed(2)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                      color:
                                                          remaining.abs() > 0.01
                                                              ? DhanWiserColors.of(context).error
                                                              : DhanWiserColors.of(context).textPrimary,
                                                      fontFeatures: const [
                                                    FontFeature.tabularFigures()
                                                  ]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),

                      // Primary Action
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: PremiumElevatedButton(
                          onPressed: _isSaving ? null : _saveExpense,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DhanWiserColors.of(context).tertiaryFixed,
                            foregroundColor: DhanWiserColors.of(context).onTertiaryFixed,
                            elevation: 8,
                            shadowColor: DhanWiserColors.of(context).tertiaryFixed
                                .withValues(alpha: 0.15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999)),
                          ),
                          child: _isSaving
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: DhanWiserColors.of(context).onTertiaryFixed))
                              : Text(
                                  'Add Expense',
                                  style:
                                      DhanWiserTextStyles.buttonLarge(context),
                                ),
                        ),
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: DhanWiserTextStyles.overline(context)
          .copyWith(letterSpacing: 0.05, color: DhanWiserColors.of(context).textSecondary),
    );
  }

  Widget _buildSplitPreviewRow(ServerMember member, double equalAmount) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isYou = member.userId == auth.currentUser?.id;
    final initial =
        member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?';
    final isSelected = _selectedUserIds.contains(member.userId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              if (_selectedUserIds.length > 1) {
                _selectedUserIds.remove(member.userId);
              }
            } else {
              _selectedUserIds.add(member.userId);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isSelected,
                      activeColor: DhanWiserColors.of(context).tertiaryFixed,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedUserIds.add(member.userId);
                          } else if (_selectedUserIds.length > 1) {
                            _selectedUserIds.remove(member.userId);
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Opacity(
                    opacity: isSelected ? 1.0 : 0.4,
                    child: Row(
                      children: [
                        if (isYou)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: DhanWiserColors.of(context).surfaceBright,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                        color: DhanWiserColors.of(context).textPrimary),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: DhanWiserColors.of(context).secondaryContainer
                                  .withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_rounded,
                                color: DhanWiserColors.of(context).secondaryFixed,
                                size: 18),
                          ),
                        const SizedBox(width: 12),
                        Text(
                          isYou ? 'You' : member.fullName,
                          style: DhanWiserTextStyles.caption(context).copyWith(
                              color: DhanWiserColors.of(context).textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Opacity(
                opacity: isSelected ? 1.0 : 0.4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DhanWiserColors.of(context).surfaceContainerLow,
                    border: Border.all(
                        color: DhanWiserColors.of(context).surfaceBright
                            .withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isSelected
                      ? Row(
                          children: [
                            Text('₹',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: DhanWiserColors.of(context).textDisabled)),
                            if (_splitType == 'equally')
                              Text(
                                equalAmount.toStringAsFixed(2),
                                style: DhanWiserTextStyles.caption(context)
                                    .copyWith(
                                        color: DhanWiserColors.of(context).textPrimary,
                                        fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ]),
                              )
                            else
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  controller:
                                      _customAmountControllers[member.userId],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  textAlign: TextAlign.right,
                                  style: DhanWiserTextStyles.caption(context)
                                      .copyWith(
                                          color: DhanWiserColors.of(context).textPrimary,
                                          fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ]),
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintText: '0.00',
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Text(
                          'Excluded',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: DhanWiserColors.of(context).textDisabled),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
