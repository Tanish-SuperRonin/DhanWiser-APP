import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../providers/server_provider.dart';

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

  // Optional pre-selected group (when opened from server detail invite button)
  int? _preSelectedServerId;
  String? _preSelectedServerName;

  // Track invite state per user: null=not invited, 'loading', 'sent', 'error'
  final Map<int, String> _inviteStates = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServerProvider>(context, listen: false).fetchServers();
      // Read route args for pre-selected server
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _preSelectedServerId = args['serverId'] as int?;
        _preSelectedServerName = args['serverName'] as String?;
      }
    });
  }

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

  void _showInviteDialog(PublicUser user) {
    // If called from a specific group context, skip group picker
    if (_preSelectedServerId != null && _preSelectedServerName != null) {
      _sendInvite(user, _preSelectedServerId!, _preSelectedServerName!);
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final sub = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;
    final serverProv = Provider.of<ServerProvider>(context, listen: false);
    final servers = serverProv.servers;

    if (servers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Create a group first before inviting friends'),
          backgroundColor: DhanWiserColors.coral,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? DhanWiserColors.gray600 : DhanWiserColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Invite ${user.fullName}',
                style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700, color: text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select a group to invite @${user.username} to:',
                style: GoogleFonts.inter(fontSize: 14, color: sub),
              ),
              const SizedBox(height: 16),
              ...servers.map((server) {
                final initial = server.name.isNotEmpty ? server.name[0].toUpperCase() : 'G';
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: DhanWiserColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(initial, style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, color: DhanWiserColors.primary, fontSize: 18)),
                    ),
                  ),
                  title: Text(server.name, style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, color: text, fontSize: 15)),
                  subtitle: Text('${server.memberCount} members', style: GoogleFonts.inter(
                    fontSize: 12, color: sub)),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: sub),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _sendInvite(user, server.id, server.name);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendInvite(PublicUser user, int serverId, String serverName) async {
    setState(() => _inviteStates[user.id] = 'loading');
    try {
      final serverProv = Provider.of<ServerProvider>(context, listen: false);
      final success = await serverProv.inviteUser(serverId, user.id);
      if (mounted) {
        if (success) {
          setState(() => _inviteStates[user.id] = 'sent');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invited ${user.fullName} to $serverName'),
              backgroundColor: DhanWiserColors.mint,
            ),
          );
        } else {
          setState(() => _inviteStates[user.id] = 'error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(serverProv.error ?? 'Failed to invite'),
              backgroundColor: DhanWiserColors.coral,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _inviteStates[user.id] = 'error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: DhanWiserColors.coral,
          ),
        );
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

  Widget _buildInviteButton(PublicUser user, Color text) {
    final state = _inviteStates[user.id];

    if (state == 'loading') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: DhanWiserColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          width: 18, height: 18,
          child: CircularProgressIndicator(
            color: DhanWiserColors.primary, strokeWidth: 2),
        ),
      );
    }

    if (state == 'sent') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: DhanWiserColors.mint.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, color: DhanWiserColors.mint, size: 16),
            const SizedBox(width: 4),
            Text('Sent', style: GoogleFonts.inter(
              color: DhanWiserColors.mint, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showInviteDialog(user),
      child: Container(
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
              _buildInviteButton(user, text),
            ],
          ),
        );
      },
    );
  }
}
