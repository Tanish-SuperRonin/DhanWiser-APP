import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class FriendDiscoveryScreen extends StatefulWidget {
  const FriendDiscoveryScreen({super.key});

  @override
  State<FriendDiscoveryScreen> createState() => _FriendDiscoveryScreenState();
}

class _FriendDiscoveryScreenState extends State<FriendDiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PublicUser> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = null;
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await UserService.searchUsers(query.trim());
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchError = 'Failed to search. Check connection.';
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Icon(Icons.arrow_back_rounded, color: text, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Find People',
                    style: GoogleFonts.inter(
                      fontSize: 22, fontWeight: FontWeight.w700,
                      color: text, letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(color: text, fontSize: 15),
                onChanged: (q) {
                  if (q.length >= 2) _performSearch(q);
                },
                onSubmitted: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Search by username or email',
                  hintStyle: GoogleFonts.inter(
                    color: isDark ? DhanWiserColors.gray500 : DhanWiserColors.gray400,
                    fontSize: 15,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: Icon(Icons.search_rounded, color: sub, size: 20),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Results ──
            Expanded(child: _buildResults(isDark, surface, text, sub)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(bool isDark, Color surface, Color text, Color sub) {
    if (_isSearching) {
      return Center(child: CircularProgressIndicator(color: DhanWiserColors.primary));
    }

    if (_searchError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: DhanWiserColors.coral, size: 32),
            const SizedBox(height: 12),
            Text(_searchError!, style: GoogleFonts.inter(color: sub, fontSize: 14)),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: DhanWiserColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.search_off_rounded, color: DhanWiserColors.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text('No users found', style: GoogleFonts.inter(
              fontSize: 17, fontWeight: FontWeight.w600, color: text)),
            const SizedBox(height: 4),
            Text('Try a different search term', style: GoogleFonts.inter(
              fontSize: 14, color: sub)),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.waving_hand_rounded, color: DhanWiserColors.primary, size: 40),
            const SizedBox(height: 16),
            Text('Find your friends', style: GoogleFonts.inter(
              fontSize: 17, fontWeight: FontWeight.w600, color: text)),
            const SizedBox(height: 4),
            Text('Search by username or email', style: GoogleFonts.inter(
              fontSize: 14, color: sub)),
          ],
        ),
      );
    }

    final userColors = [
      DhanWiserColors.primary,
      DhanWiserColors.teal,
      DhanWiserColors.coral,
      DhanWiserColors.warning,
      const Color(0xFF74B9FF),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final color = userColors[index % userColors.length];
        final initial = user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
                blurRadius: 8, offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(initial, style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: color, fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, color: text, fontSize: 15)),
                    Text('@${user.username}', style: GoogleFonts.inter(
                      fontSize: 13, color: sub)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: DhanWiserColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Invite',
                  style: GoogleFonts.inter(
                    color: DhanWiserColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
