import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/server_provider.dart';
import '../services/expense_service.dart';

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
  bool _isSaving = false;

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
      if (_selectedServerId == null) {
        Provider.of<ServerProvider>(context, listen: false).fetchServers();
      } else {
        Provider.of<ServerProvider>(context, listen: false)
            .fetchServerDetails(_selectedServerId!);
      }
    });
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

    setState(() => _isSaving = true);

    try {
      final serverProv = Provider.of<ServerProvider>(context, listen: false);
      final channels = serverProv.channels;
      final channelId = _selectedChannelId ??
          (channels.isNotEmpty ? channels.first.id : _selectedServerId!);

      await ExpenseService.addExpense(
        channelId: channelId,
        title: title,
        totalAmount: amount,
        expenseDate: DateTime.now().toIso8601String(),
        participants: [],
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
                                onChanged: (val) => setState(() => _selectedServerId = val),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

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
                    const SizedBox(height: 36),

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
