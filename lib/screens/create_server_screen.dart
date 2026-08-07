import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/server_provider.dart';

class CreateServerScreen extends StatefulWidget {
  const CreateServerScreen({super.key});

  @override
  State<CreateServerScreen> createState() => _CreateServerScreenState();
}

class _CreateServerScreenState extends State<CreateServerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _serverNameController = TextEditingController();
  bool _isPrivate = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _serverNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? cs.surfaceContainerHigh
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: cs.onPrimary,
                unselectedLabelColor: cs.onSurfaceVariant,
                labelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w400, fontSize: 13),
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.all(3),
                tabs: const [
                  Tab(text: 'Create'),
                  Tab(text: 'Discover'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Create Tab ──
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon hero
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(Icons.group_add_rounded,
                        color: cs.onPrimaryContainer, size: 36),
                  ),
                ),
                const SizedBox(height: 28),

                // Group name
                Text(
                  'GROUP NAME',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _serverNameController,
                  style: GoogleFonts.inter(color: cs.onSurface, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Flatmates, Trip Gang',
                  ),
                ),
                const SizedBox(height: 20),

                // Privacy toggle — M3 SwitchListTile in Card
                Card(
                  elevation: 0,
                  color: isDark
                      ? cs.surfaceContainerHigh
                      : cs.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      'Private Group',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Only invited members can join',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    secondary: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isPrivate
                            ? Icons.lock_rounded
                            : Icons.public_rounded,
                        color: cs.primary,
                        size: 20,
                      ),
                    ),
                    value: _isPrivate,
                    onChanged: (v) => setState(() => _isPrivate = v),
                  ),
                ),
                const SizedBox(height: 32),

                // Create button — M3 FilledButton
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isCreating
                        ? null
                        : () async {
                            final name = _serverNameController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Enter a group name'),
                                  backgroundColor: DhanWiserColors.coral,
                                ),
                              );
                              return;
                            }
                            setState(() => _isCreating = true);

                            final scaffold =
                                ScaffoldMessenger.of(context);
                            final nav = Navigator.of(context);

                            try {
                              final serverProv =
                                  Provider.of<ServerProvider>(
                                      context,
                                      listen: false);
                              final success =
                                  await serverProv.createServer(
                                name,
                                isPrivate: _isPrivate,
                              );
                              if (mounted) {
                                if (success) {
                                  scaffold.showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('$name created!'),
                                      backgroundColor:
                                          DhanWiserColors.mint,
                                    ),
                                  );
                                  nav.pop();
                                } else {
                                  scaffold.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          serverProv.error ??
                                              'Failed to create group'),
                                      backgroundColor:
                                          DhanWiserColors.coral,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                scaffold.showSnackBar(
                                  SnackBar(
                                    content: Text('Failed: $e'),
                                    backgroundColor:
                                        DhanWiserColors.coral,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isCreating = false);
                              }
                            }
                          },
                    child: _isCreating
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: cs.onPrimary,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Create Group',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // ── Discover Tab ──
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.explore_rounded,
                      color: cs.primary, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  'Discover groups',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Public groups will appear here',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
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
