import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/server_model.dart';
import '../providers/server_provider.dart';
import '../theme/colors.dart';
import '../theme/iconly_icons.dart';
import '../theme/text_styles.dart';
import '../widgets/bouncing_button.dart';

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

                        try {
                          final serverProv = Provider.of<ServerProvider>(
                              context,
                              listen: false);
                          final success = await serverProv.createServer(name,
                              isPrivate: false);
                          if (mounted) {
                            if (success) {
                              ServerModel? created;
                              for (final s in serverProv.servers) {
                                if (s.name.toLowerCase() == name.toLowerCase()) {
                                  created = s;
                                  break;
                                }
                              }
                              final newId = created?.id ?? 0;
                              _showGroupCreatedCelebration(context, newId, name);
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

  void _showGroupCreatedCelebration(BuildContext context, int serverId, String groupName) {
    final colors = DhanWiserColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primaryFixed, colors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primaryFixed.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(IconlyBold.shieldDone, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 18),
                Text(
                  'Group Ready!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '“$groupName” was created. Invite friends now so everyone is in sync.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                // Option 1: Find & Invite Friends on DhanWiser
                Material(
                  color: isDark ? colors.surfaceContainer : colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/friend-discovery',
                        arguments: {
                          'serverId': serverId,
                          'serverName': groupName,
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: colors.primaryFixed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(IconlyBold.addUser, color: colors.primaryFixed, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Invite Friends by @Username',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Search & send instant in-app invites',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(IconlyLight.arrowRight2, size: 18, color: colors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Option 2: Share Invite Link
                Material(
                  color: isDark ? colors.surfaceContainer : colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Share.share(
                        'Join my "$groupName" group on DhanWiser to split expenses easily!\n'
                        'Group code: $serverId\n'
                        'Download or join here: https://dhanwiser.vercel.app/join/$serverId',
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: colors.emerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.share_rounded, color: colors.emerald, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Share Invite Link / Code',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Share code #$serverId via WhatsApp or Messages',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(IconlyLight.arrowRight2, size: 18, color: colors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Button 3: Open Group Directly
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/server-detail',
                        arguments: {
                          'serverId': serverId,
                          'serverName': groupName,
                          'members': '1 member',
                        },
                      );
                    },
                    child: const Text('Go to Group'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
