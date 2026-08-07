import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/server_provider.dart';
import '../providers/auth_provider.dart';
import '../services/expense_service.dart';
import '../models/server_model.dart';

class AddExpenseScreen extends StatefulWidget {
  final int? serverId;

  const AddExpenseScreen({super.key, this.serverId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = 'Food';
  String _splitType = 'equally';
  int? _selectedServerId;
  int? _selectedChannelId;
  int? _paidByUserId;
  bool _isSaving = false;

  // Per-member custom amounts
  final Map<int, TextEditingController> _customAmountControllers = {};

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
        serverProv.fetchServers();
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

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) return [];

    if (_splitType == 'equally') {
      final rounded = double.parse((amount / members.length).toStringAsFixed(2));
      // Last person absorbs rounding difference so sum == amount exactly
      final remainder = double.parse(
          (amount - rounded * (members.length - 1)).toStringAsFixed(2));
      return List.generate(members.length, (i) {
        final m = members[i];
        final owed = (i == members.length - 1) ? remainder : rounded;
        return {
          'userId': m.userId,
          'amountPaid': m.userId == _paidByUserId ? amount : 0.0,
          'amountOwed': owed,
        };
      });
    } else {
      // Custom split
      return members.map((m) {
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

    // Validate custom split sums to total
    if (_splitType == 'custom') {
      double sum = 0;
      for (final m in members) {
        final controller = _customAmountControllers[m.userId];
        sum += double.tryParse(controller?.text.trim() ?? '0') ?? 0;
      }
      if ((sum - amount).abs() > 0.01) {
        _showError('Custom amounts (₹${sum.toStringAsFixed(2)}) must equal total (₹${amount.toStringAsFixed(2)})');
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
            backgroundColor: DhanWiserColors.mint,
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
        backgroundColor: DhanWiserColors.coral,
      ),
    );
  }

  void _onServerSelected(int serverId) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _selectedServerId = serverId;
      _selectedChannelId = null; // reset channel when switching servers
      _paidByUserId = auth.currentUser?.id; // reset payer to current user
    });
    Provider.of<ServerProvider>(context, listen: false)
        .fetchServerDetails(serverId).then((_) {
      // Auto-select the first channel once server details are loaded
      if (!mounted) return;
      final serverProv = Provider.of<ServerProvider>(context, listen: false);
      if (serverProv.channels.isNotEmpty) {
        setState(() => _selectedChannelId = serverProv.channels.first.id);
      }
    });
  }

  void _initCustomControllers(List<ServerMember> members) {
    for (final m in members) {
      if (!_customAmountControllers.containsKey(m.userId)) {
        _customAmountControllers[m.userId] = TextEditingController();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhanWiserColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: DhanWiserColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Expense',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: DhanWiserColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: DhanWiserColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Amount Input Hero ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Subtle Glow
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(
                    width: 192,
                    height: 192,
                    decoration: BoxDecoration(
                      color: DhanWiserColors.secondaryContainer.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds),
                ),
                
                Column(
                  children: [
                    Text(
                      'TOTAL AMOUNT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        letterSpacing: 0.05,
                        fontWeight: FontWeight.w600,
                        color: DhanWiserColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: DhanWiserColors.textPrimary.withValues(alpha: 0.6),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            onChanged: (_) => setState(() {}),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 56,
                              fontWeight: FontWeight.w700,
                              color: DhanWiserColors.textPrimary,
                              height: 1.1,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 56,
                                fontWeight: FontWeight.w700,
                                color: DhanWiserColors.textPrimary.withValues(alpha: 0.3),
                                height: 1.1,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
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
              ],
            ),
          ),
          
          // ── Form Sheet Container ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: DhanWiserColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: DhanWiserColors.surfaceBright.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: DhanWiserColors.secondaryContainer.withValues(alpha: 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, -8),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Expense Title
                      _buildSectionTitle('EXPENSE TITLE'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: DhanWiserColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.edit_rounded, color: DhanWiserColors.textSecondary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _noteController,
                                style: GoogleFonts.inter(fontSize: 16, color: DhanWiserColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Friday Dinner',
                                  hintStyle: GoogleFonts.inter(color: DhanWiserColors.textDisabled, fontSize: 16),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

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
                                onTap: () => setState(() => _selectedCategory = cat['name']!),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? DhanWiserColors.secondaryContainer.withValues(alpha: 0.2) : DhanWiserColors.background,
                                        border: Border.all(
                                          color: isSelected ? DhanWiserColors.secondaryContainer.withValues(alpha: 0.5) : DhanWiserColors.surfaceBright.withValues(alpha: 0.3),
                                        ),
                                        boxShadow: isSelected ? [
                                          BoxShadow(
                                            color: DhanWiserColors.secondaryContainer.withValues(alpha: 0.15),
                                            blurRadius: 15,
                                          )
                                        ] : null,
                                      ),
                                      child: Icon(
                                        cat['icon'],
                                        color: isSelected ? DhanWiserColors.secondaryFixed : DhanWiserColors.textSecondary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      cat['name']!,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: isSelected ? DhanWiserColors.textPrimary : DhanWiserColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Split Engine
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: DhanWiserColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: DhanWiserColors.surfaceBright.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Group Selector (Optional logic if not selected)
                            if (_selectedServerId == null) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Group', style: GoogleFonts.inter(color: DhanWiserColors.textSecondary, fontSize: 16)),
                                  Consumer<ServerProvider>(
                                    builder: (context, serverProv, _) {
                                      if (serverProv.servers.isEmpty) {
                                        return Text('No groups', style: GoogleFonts.inter(color: DhanWiserColors.textSecondary, fontSize: 14));
                                      }
                                      return DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: _selectedServerId,
                                          dropdownColor: DhanWiserColors.surface,
                                          hint: Text('Select group', style: GoogleFonts.inter(color: DhanWiserColors.textPrimary, fontSize: 14)),
                                          icon: const Icon(Icons.expand_more_rounded, color: DhanWiserColors.textDisabled, size: 16),
                                          style: GoogleFonts.inter(color: DhanWiserColors.textPrimary, fontSize: 14),
                                          onChanged: (val) {
                                            if (val != null) _onServerSelected(val);
                                          },
                                          items: serverProv.servers.map((s) {
                                            return DropdownMenuItem(value: s.id, child: Text(s.name));
                                          }).toList(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const Divider(color: DhanWiserColors.surfaceBright, height: 24),
                            ],

                            // Paid by
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Paid by', style: GoogleFonts.inter(color: DhanWiserColors.textSecondary, fontSize: 16)),
                                Consumer<ServerProvider>(
                                  builder: (context, serverProv, _) {
                                    final members = serverProv.currentServerDetail?.members ?? [];
                                    if (members.isEmpty) return const SizedBox.shrink();

                                    final auth = Provider.of<AuthProvider>(context, listen: false);
                                    final currentUserId = auth.currentUser?.id;

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: DhanWiserColors.surface,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: DhanWiserColors.surfaceBright.withValues(alpha: 0.2)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: members.any((m) => m.userId == _paidByUserId)
                                              ? _paidByUserId
                                              : (members.isNotEmpty ? members.first.userId : null),
                                          dropdownColor: DhanWiserColors.surface,
                                          icon: const Icon(Icons.expand_more_rounded, color: DhanWiserColors.textDisabled, size: 16),
                                          style: GoogleFonts.inter(color: DhanWiserColors.textPrimary, fontSize: 14),
                                          onChanged: (val) => setState(() => _paidByUserId = val),
                                          items: members.map((m) {
                                            return DropdownMenuItem(
                                              value: m.userId,
                                              child: Text(m.userId == currentUserId ? 'You' : m.fullName.split(' ')[0]),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Divider(color: DhanWiserColors.surfaceBright.withValues(alpha: 0.2), height: 32),

                            // Split with Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Split with', style: GoogleFonts.inter(color: DhanWiserColors.textSecondary, fontSize: 16)),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.group_add_rounded, size: 18),
                                  label: const Text('Add people'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: DhanWiserColors.tertiaryFixed,
                                    textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Segmented Control
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: DhanWiserColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: DhanWiserColors.surfaceBright.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _splitType = 'equally'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _splitType == 'equally' ? DhanWiserColors.tertiaryFixed : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Equally',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _splitType == 'equally' ? DhanWiserColors.background : DhanWiserColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _splitType = 'custom'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _splitType == 'custom' ? DhanWiserColors.tertiaryFixed : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Manually',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _splitType == 'custom' ? DhanWiserColors.background : DhanWiserColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Split Preview Rows
                            if (_selectedServerId != null)
                              Consumer<ServerProvider>(
                                builder: (context, serverProv, _) {
                                  final members = serverProv.currentServerDetail?.members ?? [];
                                  if (members.isEmpty) return const SizedBox.shrink();

                                  _initCustomControllers(members);
                                  final amount = double.tryParse(_amountController.text.trim()) ?? 0;
                                  final perPerson = members.isNotEmpty ? amount / members.length : 0.0;
                                  
                                  double sumCustom = 0;
                                  if (_splitType == 'custom') {
                                    for (final m in members) {
                                      sumCustom += double.tryParse(_customAmountControllers[m.userId]?.text.trim() ?? '0') ?? 0;
                                    }
                                  }
                                  final remaining = amount - sumCustom;

                                  return Column(
                                    children: [
                                      ...members.map((m) => _buildSplitPreviewRow(m, perPerson)),
                                      
                                      if (_splitType == 'custom') ...[
                                        const SizedBox(height: 12),
                                        Divider(color: DhanWiserColors.surfaceBright.withValues(alpha: 0.1), height: 1),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Remaining to split', style: GoogleFonts.inter(fontSize: 13, color: DhanWiserColors.textSecondary)),
                                            Text(
                                              '₹${remaining.toStringAsFixed(2)}',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: remaining.abs() > 0.01 ? DhanWiserColors.error : DhanWiserColors.textPrimary,
                                                fontFeatures: const [FontFeature.tabularFigures()],
                                              ),
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
                      const SizedBox(height: 32),
                      
                      // Primary Action
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveExpense,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DhanWiserColors.tertiaryFixed,
                            foregroundColor: DhanWiserColors.onTertiaryFixed,
                            elevation: 8,
                            shadowColor: DhanWiserColors.tertiaryFixed.withValues(alpha: 0.15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          ),
                          child: _isSaving
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: DhanWiserColors.onTertiaryFixed))
                              : Text(
                                  'Add Expense',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
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
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        letterSpacing: 0.05,
        fontWeight: FontWeight.w600,
        color: DhanWiserColors.textSecondary,
      ),
    );
  }

  Widget _buildSplitPreviewRow(ServerMember member, double equalAmount) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isYou = member.userId == auth.currentUser?.id;
    final initial = member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isYou)
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: DhanWiserColors.surfaceBright,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: DhanWiserColors.textPrimary, fontSize: 14),
                    ),
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: DhanWiserColors.secondaryContainer.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: DhanWiserColors.secondaryFixed, size: 18),
                ),
              const SizedBox(width: 12),
              Text(
                isYou ? 'You' : member.fullName,
                style: GoogleFonts.inter(fontSize: 14, color: DhanWiserColors.textPrimary),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DhanWiserColors.surfaceContainerLow,
              border: Border.all(color: DhanWiserColors.surfaceBright.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Text('₹', style: GoogleFonts.inter(fontSize: 12, color: DhanWiserColors.textDisabled)),
                if (_splitType == 'equally')
                  Text(
                    equalAmount.toStringAsFixed(2),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: DhanWiserColors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  )
                else
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _customAmountControllers[member.userId],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: DhanWiserColors.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
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
            ),
          ),
        ],
      ),
    );
  }
}
