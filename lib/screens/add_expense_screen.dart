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
          final prov = Provider.of<ServerProvider>(context, listen: false);
          if (prov.channels.isNotEmpty && mounted) {
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
        final serverProv = Provider.of<ServerProvider>(context, listen: false);
        var channels = serverProv.channels;
        if (channels.isEmpty) {
          // Fetch fresh from server (backend will auto-create General channel)
          await serverProv.fetchServerDetails(_selectedServerId!);
          channels = serverProv.channels;
        }
        if (channels.isEmpty) {
          if (mounted) _showError('Could not load channels. Please try again.');
          return;
        }
        channelId = channels.first.id;
        if (mounted) setState(() => _selectedChannelId = channelId);
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
    setState(() {
      _selectedServerId = serverId;
      _selectedChannelId = null; // reset channel when switching servers
    });
    Provider.of<ServerProvider>(context, listen: false)
        .fetchServerDetails(serverId).then((_) {
      // Auto-select the first channel once server details are loaded
      final serverProv = Provider.of<ServerProvider>(context, listen: false);
      if (serverProv.channels.isNotEmpty && mounted) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final text = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final sub = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? DhanWiserColors.surfaceElevatedDark : DhanWiserColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.close_rounded, color: text, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'New Expense',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: text,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

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
                              color: sub,
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
                                color: text,
                                letterSpacing: -2,
                              ),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: sub.withValues(alpha: 0.3),
                                  letterSpacing: -2,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Note ──
                    _buildLabel('What\'s it for?', sub),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      style: GoogleFonts.inter(color: text, fontSize: 15),
                      decoration: _inputDecoration('e.g. Dinner, Uber, Groceries', isDark),
                    ),
                    const SizedBox(height: 20),

                    // ── Category pills ──
                    _buildLabel('Category', sub),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat['name'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat['name']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? DhanWiserColors.primary
                                  : (isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.gray100),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? null
                                  : Border.all(color: isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cat['icon'] as IconData, size: 16, color: isSelected ? Colors.white : DhanWiserColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  cat['name']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.white : text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Group selector ──
                    if (_selectedServerId == null) ...[
                      _buildLabel('Group', sub),
                      const SizedBox(height: 8),
                      Consumer<ServerProvider>(
                        builder: (context, serverProv, _) {
                          if (serverProv.servers.isEmpty) {
                            return Text('No groups available',
                                style: GoogleFonts.inter(color: sub, fontSize: 14));
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark ? DhanWiserColors.inputDark : DhanWiserColors.inputLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                hint: Text('Select a group',
                                    style: GoogleFonts.inter(color: sub, fontSize: 15)),
                                value: _selectedServerId,
                                dropdownColor: isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
                                style: GoogleFonts.inter(color: text, fontSize: 15),
                                items: serverProv.servers.map((s) {
                                  return DropdownMenuItem(
                                    value: s.id,
                                    child: Text(s.name),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) _onServerSelected(val);
                                },
                              ),
                            ),
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
                                  setState(() => _selectedChannelId = chList.first.id);
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
                          final members = serverProv.currentServerDetail?.members ?? [];
                          if (members.isEmpty) return const SizedBox.shrink();

                          // Set default paidBy if not set
                          if (_paidByUserId == null && members.isNotEmpty) {
                            final auth = Provider.of<AuthProvider>(context, listen: false);
                            _paidByUserId = auth.currentUser?.id ?? members.first.userId;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Paid by', sub),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isDark ? DhanWiserColors.inputDark : DhanWiserColors.inputLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: members.any((m) => m.userId == _paidByUserId)
                                        ? _paidByUserId
                                        : members.first.userId,
                                    dropdownColor: isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
                                    style: GoogleFonts.inter(color: text, fontSize: 15),
                                    items: members.map((m) {
                                      return DropdownMenuItem(
                                        value: m.userId,
                                        child: Text('${m.fullName} (@${m.username})'),
                                      );
                                    }).toList(),
                                    onChanged: (val) => setState(() => _paidByUserId = val),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),

                    // ── Split type ──
                    _buildLabel('Split', sub),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildSplitChip('Equally', 'equally', Icons.balance_rounded, isDark, text),
                        const SizedBox(width: 10),
                        _buildSplitChip('Custom', 'custom', Icons.tune_rounded, isDark, text),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Split details ──
                    if (_selectedServerId != null)
                      Consumer<ServerProvider>(
                        builder: (context, serverProv, _) {
                          final members = serverProv.currentServerDetail?.members ?? [];
                          if (members.isEmpty) {
                            if (serverProv.isLoading) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator(
                                  color: DhanWiserColors.primary, strokeWidth: 2)),
                              );
                            }
                            return const SizedBox.shrink();
                          }

                          _initCustomControllers(members);
                          final amount = double.tryParse(_amountController.text.trim()) ?? 0;
                          final perPerson = members.isNotEmpty ? amount / members.length : 0.0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                _splitType == 'equally'
                                    ? 'Split equally (₹${perPerson.toStringAsFixed(2)} each)'
                                    : 'Custom amounts (must total ₹${amount.toStringAsFixed(2)})',
                                sub,
                              ),
                              const SizedBox(height: 10),
                              ...members.map((m) {
                                return _buildMemberSplitRow(m, perPerson, isDark, text, sub);
                              }),
                            ],
                          );
                        },
                      ),

                    const SizedBox(height: 20),

                    // ── Save button ──
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DhanWiserColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: DhanWiserColors.primary.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
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
      ),
    );
  }

  Widget _buildMemberSplitRow(ServerMember member, double equalAmount, bool isDark, Color text, Color sub) {
    final initial = member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?';
    final isPayer = member.userId == _paidByUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isPayer
            ? Border.all(color: DhanWiserColors.primary.withValues(alpha: 0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.02),
            blurRadius: 6, offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: DhanWiserColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(initial, style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: DhanWiserColors.primary, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.fullName, style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, color: text, fontSize: 14)),
                if (isPayer)
                  Text('Payer', style: GoogleFonts.inter(
                    fontSize: 11, color: DhanWiserColors.primary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (_splitType == 'equally')
            Text(
              '₹${equalAmount.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w600, color: text),
            )
          else
            SizedBox(
              width: 90,
              child: TextField(
                controller: _customAmountControllers[member.userId],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: text),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: GoogleFonts.inter(color: sub.withValues(alpha: 0.4), fontSize: 15),
                  prefixText: '₹',
                  prefixStyle: GoogleFonts.inter(color: sub, fontSize: 15),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  filled: true,
                  fillColor: isDark ? DhanWiserColors.inputDark : DhanWiserColors.inputLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, Color color) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildSplitChip(String label, String value, IconData icon, bool isDark, Color text) {
    final isSelected = _splitType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _splitType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? DhanWiserColors.primary.withValues(alpha: 0.1)
                : (isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.gray100),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? DhanWiserColors.primary.withValues(alpha: 0.4)
                  : (isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray200),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? DhanWiserColors.primary : text),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? DhanWiserColors.primary : text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: isDark ? DhanWiserColors.gray500 : DhanWiserColors.gray400,
        fontSize: 15,
      ),
      filled: true,
      fillColor: isDark ? DhanWiserColors.inputDark : DhanWiserColors.inputLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: DhanWiserColors.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
