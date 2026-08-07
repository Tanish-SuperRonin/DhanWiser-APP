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

    final cs = Theme.of(context).colorScheme;
    final serverProv = Provider.of<ServerProvider>(context, listen: false);
    final servers = serverProv.servers;

    if (servers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Create a group first before inviting friends'),
          backgroundColor: DhanWiserColors.coral,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Invite ${user.fullName}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select a group to invite @${user.username} to:',
                style:
                    GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ...servers.map((server) {
                final initial = server.name.isNotEmpty
                    ? server.name[0].toUpperCase()
                    : 'G';
                return ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    server.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    '${server.memberCount} members',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: cs.onSurfaceVariant),
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

  Future<void> _sendInvite(
      PublicUser user, int serverId, String serverName) async {
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find People'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search by username or email',
              leading: Icon(Icons.search_rounded,
                  color: cs.onSurfaceVariant, size: 22),
              onChanged: (q) {
                if (q.length >= 2) _performSearch(q);
              },
              onSubmitted: _performSearch,
              textStyle: WidgetStateProperty.all(
                GoogleFonts.inter(color: cs.onSurface, fontSize: 15),
              ),
              elevation: WidgetStateProperty.all(0),
              backgroundColor:
                  WidgetStateProperty.all(isDark
                      ? cs.surfaceContainerHigh
                      : cs.surfaceContainerHighest),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Results ──
          Expanded(child: _buildResults(cs, isDark)),
        ],
      ),
    );
  }

  Widget _buildInviteButton(PublicUser user, ColorScheme cs) {
    final state = _inviteStates[user.id];

    if (state == 'loading') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
              color: cs.primary, strokeWidth: 2),
        ),
      );
    }

    if (state == 'sent') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: DhanWiserColors.mint.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, color: DhanWiserColors.mint, size: 16),
            const SizedBox(width: 4),
            Text(
              'Sent',
              style: GoogleFonts.inter(
                color: DhanWiserColors.mint,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return FilledButton.tonal(
      onPressed: () => _showInviteDialog(user),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Invite',
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildResults(ColorScheme cs, bool isDark) {
    if (_isSearching) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    if (_searchError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: cs.error, size: 32),
            const SizedBox(height: 12),
            Text(_searchError!,
                style:
                    GoogleFonts.inter(color: cs.onSurfaceVariant, fontSize: 14)),
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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child:
                  Icon(Icons.search_off_rounded, color: cs.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try a different search term',
              style: GoogleFonts.inter(
                  fontSize: 14, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.waving_hand_rounded, color: cs.primary, size: 40),
            const SizedBox(height: 16),
            Text(
              'Find your friends',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Search by username or email',
              style: GoogleFonts.inter(
                  fontSize: 14, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    final userColors = [
      DhanWiserColors.primary,
      DhanWiserColors.teal,
      DhanWiserColors.coral,
      DhanWiserColors.warning,
      DhanWiserColors.tertiary,
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final color = userColors[index % userColors.length];
        final initial =
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: isDark
              ? cs.surfaceContainerHigh
              : cs.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '@${user.username}',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _buildInviteButton(user, cs),
              ],
            ),
          ),
        );
      },
    );
  }
}
