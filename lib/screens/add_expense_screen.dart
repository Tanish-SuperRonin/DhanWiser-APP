import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = 'Food';
  String _splitType = 'equally'; // equally, you_owe, they_owe

  final List<String> _categories = ['Food', 'Transport', 'Rent', 'Utilities', 'Entropy', 'Groceries', 'Entertainment'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final surfaceColor = isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.surfaceLight;
    final textColor = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final subTextColor = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;
    final borderColor = isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray200;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Expense',
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
               // Validate and save expense
               Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: DhanWiserColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Input
            Center(
              child: IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: subTextColor,
                    ),
                    hintText: '0',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: subTextColor,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),

            // Note Input
            TextField(
              controller: _noteController,
              style: GoogleFonts.inter(color: textColor),
              decoration: InputDecoration(
                hintText: 'What is this for?',
                hintStyle: GoogleFonts.inter(color: subTextColor),
                filled: true,
                fillColor: surfaceColor,
                prefixIcon: Icon(Icons.edit_note, color: subTextColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: DhanWiserColors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Category Selection
            Text(
              'Category',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(
                    category,
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category);
                  },
                  selectedColor: DhanWiserColors.primary,
                  backgroundColor: isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.gray100,
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : borderColor,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                 // labelStyle: TextStyle(color: isSelected ? Colors.white : textColor),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Split Selection
            Text(
              'Split with',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),

             // Selected People (Mock)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                   _buildPersonAvatar(
                    'You',
                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
                    true,
                  ),
                  _buildPersonAvatar(
                    'Rahul',
                    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
                    true,
                  ),
                  _buildPersonAvatar(
                    'Priya',
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
                    false, // Not selected
                  ),
                  // Add Button
                  Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.gray100,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, style: BorderStyle.solid), // Dashed border workaround needed if exact design required
                        ),
                        child: Icon(Icons.add, color: subTextColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add',
                         style: GoogleFonts.inter(
                          fontSize: 12,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

             // Split Options
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                   _buildSplitOption('Equally', 'equally', isDark),
                   _buildSplitOption('You owe', 'you_owe', isDark),
                   _buildSplitOption('They owe', 'they_owe', isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonAvatar(String name, String imageUrl, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: DhanWiserColors.primary, width: 2) : null,
                ),
                padding: const EdgeInsets.all(2), // Space for border
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(imageUrl),
                ),
              ),
              if (isSelected)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: DhanWiserColors.primary,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? DhanWiserColors.primary : DhanWiserColors.textSecondaryLight, // Using light for subTextColor convenience here, should be context aware realistically
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitOption(String label, String value, bool isDark) {
    final isSelected = _splitType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _splitType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDark ? DhanWiserColors.gray700 : Colors.white) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
             boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected 
                  ? (isDark ? Colors.white : DhanWiserColors.textPrimaryLight) 
                  : (isDark ? DhanWiserColors.gray400 : DhanWiserColors.gray500),
            ),
          ),
        ),
      ),
    );
  }
}
