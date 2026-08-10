import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/server_provider.dart';
import 'package:dhanwiser_fixed/theme/text_styles.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

class CreateServerScreen extends StatefulWidget {
  const CreateServerScreen({super.key});

  @override
  State<CreateServerScreen> createState() => _CreateServerScreenState();
}

class _CreateServerScreenState extends State<CreateServerScreen> {
  final TextEditingController _serverNameController = TextEditingController();
  final TextEditingController _serverDescController = TextEditingController();
  bool _isCreating = false;
  String _selectedCategory = 'Trip';
  String _selectedCurrency = 'USD';

  final List<String> _categories = ['Trip', 'Home', 'Couple', 'Other'];
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'INR'];

  @override
  void dispose() {
    _serverNameController.dispose();
    _serverDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhanWiserColors.of(context).background,
      appBar: AppBar(
        backgroundColor: DhanWiserColors.of(context).background,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: PremiumIconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: DhanWiserColors.of(context).textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Group',
          style: DhanWiserTextStyles.buttonLarge(context)
              .copyWith(color: DhanWiserColors.of(context).primary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Uploader
            Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: DhanWiserColors.of(context).surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DhanWiserColors.of(context).primaryContainer
                          .withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(48),
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: DhanWiserColors.of(context).primaryContainer
                                      .withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                )
                              ],
                            ),
                          ),
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: DhanWiserColors.of(context).primaryContainer
                                .withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add Group Photo',
                  style: DhanWiserTextStyles.caption(context)
                      .copyWith(color: DhanWiserColors.of(context).textSecondary),
                ),
              ],
            ),
            SizedBox(height: 32),

            // Form Fields
            Text(
              'Group Name',
              style: DhanWiserTextStyles.overline(context).copyWith(
                  letterSpacing: 0.5, color: DhanWiserColors.of(context).textSecondary),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _serverNameController,
              style: DhanWiserTextStyles.bodyRegular(context)
                  .copyWith(color: DhanWiserColors.of(context).primary),
              decoration: InputDecoration(
                hintText: 'e.g. Paris Trip 2024',
                hintStyle: DhanWiserTextStyles.bodyRegular(context)
                    .copyWith(color: DhanWiserColors.of(context).textDisabled),
                filled: true,
                fillColor: DhanWiserColors.of(context).surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: DhanWiserColors.of(context).outlineVariant
                          .withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: DhanWiserColors.of(context).outlineVariant
                          .withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: DhanWiserColors.of(context).primaryContainer),
                ),
              ),
            ),
            SizedBox(height: 16),

            Text(
              'Description (Optional)',
              style: DhanWiserTextStyles.overline(context).copyWith(
                  letterSpacing: 0.5, color: DhanWiserColors.of(context).textSecondary),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _serverDescController,
              style: DhanWiserTextStyles.bodyRegular(context)
                  .copyWith(color: DhanWiserColors.of(context).primary),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "What's this group for?",
                hintStyle: DhanWiserTextStyles.bodyRegular(context)
                    .copyWith(color: DhanWiserColors.of(context).textDisabled),
                filled: true,
                fillColor: DhanWiserColors.of(context).surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: DhanWiserColors.of(context).outlineVariant
                          .withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: DhanWiserColors.of(context).outlineVariant
                          .withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: DhanWiserColors.of(context).primaryContainer),
                ),
              ),
            ),
            SizedBox(height: 32),

            // Category Selector
            Text(
              'Category',
              style: DhanWiserTextStyles.overline(context).copyWith(
                  letterSpacing: 0.5, color: DhanWiserColors.of(context).textSecondary),
            ),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  IconData icon;
                  switch (category) {
                    case 'Trip':
                      icon = Icons.flight_takeoff_rounded;
                      break;
                    case 'Home':
                      icon = Icons.home_rounded;
                      break;
                    case 'Couple':
                      icon = Icons.favorite_rounded;
                      break;
                    default:
                      icon = Icons.category_rounded;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? DhanWiserColors.of(context).surfaceContainerHigh
                              : DhanWiserColors.of(context).surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected
                                ? DhanWiserColors.of(context).primaryContainer
                                    .withValues(alpha: 0.5)
                                : DhanWiserColors.of(context).outlineVariant
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon,
                                size: 16,
                                color: isSelected
                                    ? DhanWiserColors.of(context).primaryContainer
                                    : DhanWiserColors.of(context).textSecondary),
                            SizedBox(width: 8),
                            Text(
                              category,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      color: isSelected
                                          ? DhanWiserColors.of(context).primaryContainer
                                          : DhanWiserColors.of(context).textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 32),

            // Currency Selector
            Text(
              'Base Currency',
              style: DhanWiserTextStyles.overline(context).copyWith(
                  letterSpacing: 0.5, color: DhanWiserColors.of(context).textSecondary),
            ),
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: DhanWiserColors.of(context).surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color:
                        DhanWiserColors.of(context).outlineVariant.withValues(alpha: 0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  dropdownColor: DhanWiserColors.of(context).surfaceContainerHigh,
                  icon: Icon(Icons.expand_more_rounded,
                      color: DhanWiserColors.of(context).textSecondary),
                  isExpanded: true,
                  items: _currencies.map((currency) {
                    String symbol = '';
                    switch (currency) {
                      case 'USD':
                        symbol = '\$';
                        break;
                      case 'EUR':
                        symbol = '€';
                        break;
                      case 'GBP':
                        symbol = '£';
                        break;
                      case 'INR':
                        symbol = '₹';
                        break;
                    }
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(
                        '$currency ($symbol)',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: DhanWiserColors.of(context).primary),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCurrency = val);
                  },
                ),
              ),
            ),
            SizedBox(height: 48),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: PremiumElevatedButton(
                onPressed: _isCreating
                    ? null
                    : () async {
                        final name = _serverNameController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: const Text('Enter a group name'),
                                backgroundColor: DhanWiserColors.of(context).coral),
                          );
                          return;
                        }
                        setState(() => _isCreating = true);

                        final scaffold = ScaffoldMessenger.of(context);
                        final nav = Navigator.of(context);

                        try {
                          final serverProv = Provider.of<ServerProvider>(
                              context,
                              listen: false);
                          // We pass _isPrivate: false by default as the UI doesn't have it anymore
                          final success = await serverProv.createServer(name,
                              isPrivate: false);
                          if (mounted) {
                            if (success) {
                              scaffold.showSnackBar(
                                SnackBar(
                                    content: Text('$name created!'),
                                    backgroundColor: DhanWiserColors.of(context).mint),
                              );
                              nav.pop();
                            } else {
                              scaffold.showSnackBar(
                                SnackBar(
                                    content: Text(serverProv.error ??
                                        'Failed to create group'),
                                    backgroundColor: DhanWiserColors.of(context).coral),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            scaffold.showSnackBar(
                              SnackBar(
                                  content: Text('Failed: $e'),
                                  backgroundColor: DhanWiserColors.of(context).coral),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isCreating = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DhanWiserColors.of(context).primaryContainer,
                  foregroundColor: DhanWiserColors.of(context).onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                  elevation: 4,
                  shadowColor:
                      DhanWiserColors.of(context).primaryContainer.withValues(alpha: 0.2),
                ),
                child: _isCreating
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: DhanWiserColors.of(context).onPrimary, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Create Group',
                              style: Theme.of(context).textTheme.titleMedium!),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
