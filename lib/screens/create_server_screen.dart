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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final text = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final sub = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;
    final surface = isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white;

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
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? DhanWiserColors.surfaceElevatedDark : DhanWiserColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.close_rounded, color: text, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'New Group',
                    style: GoogleFonts.inter(
                      fontSize: 22, fontWeight: FontWeight.w700,
                      color: text, letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Tabs ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.gray100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: DhanWiserColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: sub,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 13),
                  dividerColor: Colors.transparent,
                  padding: const EdgeInsets.all(3),
                  tabs: const [
                    Tab(text: 'Create'),
                    Tab(text: 'Discover'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Create Tab ──
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon chooser
                        Center(
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [DhanWiserColors.primary, DhanWiserColors.primaryLight],
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(Icons.group_add_rounded, color: Colors.white, size: 36),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Group name
                        Text('GROUP NAME', style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600, color: sub, letterSpacing: 0.8)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _serverNameController,
                          style: GoogleFonts.inter(color: text, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'e.g. Flatmates, Trip Gang',
                            hintStyle: GoogleFonts.inter(color: isDark ? DhanWiserColors.gray500 : DhanWiserColors.gray400, fontSize: 15),
                            filled: true,
                            fillColor: isDark ? DhanWiserColors.inputDark : DhanWiserColors.inputLight,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: DhanWiserColors.primary.withValues(alpha: 0.5), width: 1.5)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Privacy toggle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
                                blurRadius: 8, offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: DhanWiserColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _isPrivate ? Icons.lock_rounded : Icons.public_rounded,
                                  color: DhanWiserColors.primary, size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Private Group', style: GoogleFonts.inter(
                                      fontSize: 15, fontWeight: FontWeight.w500, color: text)),
                                    Text('Only invited members can join', style: GoogleFonts.inter(
                                      fontSize: 12, color: sub)),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _isPrivate,
                                onChanged: (v) => setState(() => _isPrivate = v),
                                activeTrackColor: DhanWiserColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Create button
                        SizedBox(
                          width: double.infinity, height: 56,
                          child: ElevatedButton(
                            onPressed: _isCreating ? null : () async {
                              final name = _serverNameController.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Enter a group name'), backgroundColor: DhanWiserColors.coral),
                                );
                                return;
                              }
                              setState(() => _isCreating = true);

                              final scaffold = ScaffoldMessenger.of(context);
                              final nav = Navigator.of(context);

                              try {
                                final serverProv = Provider.of<ServerProvider>(context, listen: false);
                                await serverProv.createServer(name);
                                if (mounted) {
                                  scaffold.showSnackBar(
                                    SnackBar(content: Text('$name created!'), backgroundColor: DhanWiserColors.mint),
                                  );
                                  nav.pop();
                                }
                              } catch (e) {
                                if (mounted) {
                                  scaffold.showSnackBar(
                                    SnackBar(content: Text('Failed: $e'), backgroundColor: DhanWiserColors.coral),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isCreating = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DhanWiserColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: DhanWiserColors.primary.withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isCreating
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : Text('Create Group', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
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
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            color: DhanWiserColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.explore_rounded, color: DhanWiserColors.primary, size: 28),
                        ),
                        const SizedBox(height: 16),
                        Text('Discover groups', style: GoogleFonts.inter(
                          fontSize: 17, fontWeight: FontWeight.w600, color: text)),
                        const SizedBox(height: 4),
                        Text('Public groups will appear here', style: GoogleFonts.inter(
                          fontSize: 14, color: sub)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
