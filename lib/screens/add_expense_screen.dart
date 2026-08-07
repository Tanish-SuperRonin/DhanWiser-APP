import 'package:flutter/material.dart';
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Expense'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Body ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ── Amount input (hero) ──
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '₹',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            onChanged: (_) => setState(() {}),
                            style: GoogleFonts.inter(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              letterSpacing: -2,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                                letterSpacing: -2,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Note ──
                  _buildLabel('What\'s it for?', cs),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    style: GoogleFonts.inter(color: cs.onSurface, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'e.g. Dinner, Uber, Groceries',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Category pills — M3 Filter Chips ──
                  _buildLabel('Category', cs),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['name'];
                      return FilterChip(
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = cat['name']!),
                        avatar: Icon(
                          cat['icon'] as IconData,
                          size: 18,
                          color: isSelected ? cs.primary : cs.onSurfaceVariant,
                        ),
                        label: Text(cat['name']! as String),
                        selectedColor: cs.primaryContainer,
                        checkmarkColor: cs.primary,
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── Group selector ──
                  if (_selectedServerId == null) ...[
                    _buildLabel('Group', cs),
                    const SizedBox(height: 8),
                    Consumer<ServerProvider>(
                      builder: (context, serverProv, _) {
                        if (serverProv.servers.isEmpty) {
                          return Text('No groups available',
                              style: GoogleFonts.inter(
                                  color: cs.onSurfaceVariant, fontSize: 14));
                        }
                        return DropdownMenu<int>(
                          width: double.infinity,
                          hintText: 'Select a group',
                          inputDecorationTheme: Theme.of(context).inputDecorationTheme,
                          textStyle: GoogleFonts.inter(
                              color: cs.onSurface, fontSize: 15),
                          onSelected: (val) {
                            if (val != null) _onServerSelected(val);
                          },
                          dropdownMenuEntries: serverProv.servers.map((s) {
                            return DropdownMenuEntry(
                              value: s.id,
                              label: s.name,
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Auto-select channel (hidden from user) ──
                  if (_selectedServerId != null)
                    Consumer<ServerProvider>(
                      builder: (context, serverProv, _) {
                        final chList = serverProv.channels;
                        if (chList.isNotEmpty) {
                          // Auto-select first channel if not already set
                          if (_selectedChannelId == null ||
                              !chList.any((c) => c.id == _selectedChannelId)) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(
                                    () => _selectedChannelId = chList.first.id);
                              }
                            });
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                  // ── Paid by selector ──
                  if (_selectedServerId != null)
                    Consumer<ServerProvider>(
                      builder: (context, serverProv, _) {
                        final members =
                            serverProv.currentServerDetail?.members ?? [];
                        if (members.isEmpty) return const SizedBox.shrink();

                        // Set default paidBy if not set
                        if (_paidByUserId == null && members.isNotEmpty) {
                          final auth = Provider.of<AuthProvider>(context,
                              listen: false);
                          _paidByUserId =
                              auth.currentUser?.id ?? members.first.userId;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Paid by', cs),
                            const SizedBox(height: 8),
                            DropdownMenu<int>(
                              width: double.infinity,
                              initialSelection:
                                  members.any((m) => m.userId == _paidByUserId)
                                      ? _paidByUserId
                                      : members.first.userId,
                              textStyle: GoogleFonts.inter(
                                  color: cs.onSurface, fontSize: 15),
                              inputDecorationTheme: Theme.of(context).inputDecorationTheme,
                              onSelected: (val) =>
                                  setState(() => _paidByUserId = val),
                              dropdownMenuEntries: members.map((m) {
                                return DropdownMenuEntry(
                                  value: m.userId,
                                  label:
                                      '${m.fullName} (@${m.username})',
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),

                  // ── Split type — M3 Segmented Button ──
                  _buildLabel('Split', cs),
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'equally',
                        label: Text('Equally'),
                        icon: Icon(Icons.balance_rounded),
                      ),
                      ButtonSegment(
                        value: 'custom',
                        label: Text('Custom'),
                        icon: Icon(Icons.tune_rounded),
                      ),
                    ],
                    selected: {_splitType},
                    onSelectionChanged: (sel) =>
                        setState(() => _splitType = sel.first),
                  ),
                  const SizedBox(height: 20),

                  // ── Split details ──
                  if (_selectedServerId != null)
                    Consumer<ServerProvider>(
                      builder: (context, serverProv, _) {
                        final members =
                            serverProv.currentServerDetail?.members ?? [];
                        if (members.isEmpty) {
                          if (serverProv.isLoading) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: cs.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }

                        _initCustomControllers(members);
                        final amount =
                            double.tryParse(_amountController.text.trim()) ??
                                0;
                        final perPerson = members.isNotEmpty
                            ? amount / members.length
                            : 0.0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(
                              _splitType == 'equally'
                                  ? 'Split equally (₹${perPerson.toStringAsFixed(2)} each)'
                                  : 'Custom amounts (must total ₹${amount.toStringAsFixed(2)})',
                              cs,
                            ),
                            const SizedBox(height: 10),
                            ...members.map((m) {
                              return _buildMemberSplitRow(
                                  m, perPerson, cs, isDark);
                            }),
                          ],
                        );
                      },
                    ),

                  const SizedBox(height: 20),

                  // ── Save button — M3 FilledButton ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _saveExpense,
                      child: _isSaving
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: cs.onPrimary,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Add Expense',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSplitRow(
      ServerMember member, double equalAmount, ColorScheme cs, bool isDark) {
    final initial =
        member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?';
    final isPayer = member.userId == _paidByUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isPayer
            ? BorderSide(color: cs.primary.withValues(alpha: 0.3), width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      fontSize: 14,
                    ),
                  ),
                  if (isPayer)
                    Text(
                      'Payer',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (_splitType == 'equally')
              Text(
                '₹${equalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              )
            else
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _customAmountControllers[member.userId],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixText: '₹',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label, ColorScheme cs) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: cs.onSurfaceVariant,
        letterSpacing: 0.3,
      ),
    );
  }
}
