import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/server_provider.dart';
import '../services/user_service.dart';
import '../theme/colors.dart';
import '../theme/iconly_icons.dart';
import 'join_group_screen.dart';

class FriendDiscoveryScreen extends StatefulWidget {
  final bool isRootTab;
  final String? initialQuery;
  const FriendDiscoveryScreen({
    super.key,
    this.isRootTab = false,
    this.initialQuery,
  });

  @override
  State<FriendDiscoveryScreen> createState() => _FriendDiscoveryScreenState();
}

class _FriendDiscoveryScreenState extends State<FriendDiscoveryScreen> {
  late final TextEditingController _searchController;
  List<PublicUser> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  // Optional pre-selected group
  int? _preSelectedServerId;
  String? _preSelectedServerName;

  // Track invite state per user: null, 'loading', 'sent', 'error'
  final Map<int, String> _inviteStates = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServerProvider>(context, listen: false).fetchServers();
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        setState(() {
          _preSelectedServerId = args['serverId'] as int?;
          _preSelectedServerName = args['serverName'] as String?;
          if (args['query'] is String && (args['query'] as String).isNotEmpty) {
            _searchController.text = args['query'] as String;
            _performSearch(args['query'] as String);
          }
        });
      } else if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _performSearch(widget.initialQuery!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final clean = query.trim().replaceAll('@', '');
    if (clean.isEmpty) {
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
      final results = await UserService.searchUsers(clean);
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
          _searchError = 'Unable to search users. Please check connection.';
        });
      }
    }
  }

  void _showInviteDialog(PublicUser user) {
    if (_preSelectedServerId != null && _preSelectedServerName != null) {
      _sendInvite(user, _preSelectedServerId!, _preSelectedServerName!);
      return;
    }

    final colors = DhanWiserColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final serverProv = Provider.of<ServerProvider>(context, listen: false);
    final servers = serverProv.servers;

    if (servers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Create a group first before inviting friends'),
          backgroundColor: colors.coral,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Invite ${user.fullName}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select which group to add @${user.username} to:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: servers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final server = servers[index];
                      final initial = server.name.isNotEmpty
                          ? server.name[0].toUpperCase()
                          : 'G';
                      return InkWell(
                        onTap: () async {
                          Navigator.pop(ctx);
                          await _sendInvite(user, server.id, server.name);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colors.primaryFixed
                                      .withValues(alpha: isDark ? 0.2 : 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    initial,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      color: colors.primaryFixed,
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
                                      server.name,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${server.memberCount} members',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                IconlyLight.arrowRight2,
                                size: 16,
                                color: colors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendInvite(
      PublicUser user, int serverId, String serverName) async {
    setState(() => _inviteStates[user.id] = 'loading');
    final colors = DhanWiserColors.of(context);
    try {
      final serverProv = Provider.of<ServerProvider>(context, listen: false);
      final success = await serverProv.inviteUser(serverId, user.id);
      if (mounted) {
        if (success) {
          setState(() => _inviteStates[user.id] = 'sent');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invited ${user.fullName} to $serverName'),
              backgroundColor: colors.emerald,
            ),
          );
        } else {
          setState(() => _inviteStates[user.id] = 'error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(serverProv.error ?? 'Failed to invite user'),
              backgroundColor: colors.coral,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _inviteStates[user.id] = 'error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation error: $e'),
            backgroundColor: colors.coral,
          ),
        );
      }
    }
  }

  void _showJoinWithCodeDialog() {
    final controller = TextEditingController();
    final colors = DhanWiserColors.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Join Group with Code',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: colors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the group ID or paste invite link shared by your friend:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.text,
              autofocus: true,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. 104 or join/104',
                prefixIcon: Icon(IconlyLight.user2, color: colors.textSecondary),
                filled: true,
                fillColor: colors.surfaceContainer,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              final raw = controller.text.trim();
              if (raw.isEmpty) return;
              final match = RegExp(r'\d+').firstMatch(raw);
              if (match != null) {
                final id = int.tryParse(match.group(0)!);
                if (id != null) {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JoinGroupScreen(serverId: id),
                    ),
                  );
                  return;
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Please enter a valid numeric group code'),
                  backgroundColor: colors.coral,
                ),
              );
            },
            child: const Text('Join Group'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = DhanWiserColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: widget.isRootTab
            ? null
            : IconButton(
                icon: Icon(IconlyLight.arrowLeft2, color: colors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          _preSelectedServerName != null
              ? 'Invite to $_preSelectedServerName'
              : 'Find Friends',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Join with group code',
            icon: Icon(IconlyLight.document, color: colors.textPrimary),
            onPressed: _showJoinWithCodeDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name, @username, or email...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
                prefixIcon: Icon(IconlyLight.search, color: colors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colors.surfaceContainer,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.primaryFixed, width: 1.5),
                ),
              ),
              onChanged: (q) {
                if (q.length >= 2) {
                  _performSearch(q);
                } else if (q.isEmpty) {
                  setState(() => _searchResults = []);
                }
              },
              onSubmitted: _performSearch,
            ),
          ),

          Expanded(child: _buildBody(colors, isDark)),
        ],
      ),
    );
  }

  Widget _buildBody(DhanWiserColors colors, bool isDark) {
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(color: colors.primaryFixed),
      );
    }

    if (_searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(IconlyBold.danger, color: colors.coral, size: 36),
              const SizedBox(height: 12),
              Text(
                _searchError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(IconlyLight.search, color: colors.textSecondary, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'No users found',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Make sure the username or email is spelled correctly.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildDiscoveryHub(colors, isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            '${_searchResults.length} ${_searchResults.length == 1 ? 'user found' : 'users found'}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final user = _searchResults[index];
              final displayName = user.fullName.trim().isNotEmpty
                  ? user.fullName.trim()
                  : user.username;
              final initial =
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.primaryFixed.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: colors.primaryFixed,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@${user.username}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildInviteButton(user, colors),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInviteButton(PublicUser user, DhanWiserColors colors) {
    final state = _inviteStates[user.id];

    if (state == 'loading') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(100),
        ),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            color: colors.primaryFixed,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (state == 'sent') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: colors.emerald.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(IconlyBold.shieldDone, size: 14, color: colors.emerald),
            const SizedBox(width: 4),
            Text(
              'Invited',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.emerald,
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
        visualDensity: VisualDensity.compact,
      ),
      child: const Text('Invite'),
    );
  }

  Widget _buildDiscoveryHub(DhanWiserColors colors, bool isDark) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final username = user?.username ?? 'user';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── My Shareable Profile Card ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        colors.surfaceContainer,
                        colors.surfaceContainerHighest,
                      ]
                    : [
                        colors.surfaceContainerLowest,
                        colors.surfaceContainerLow,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: colors.primaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (user?.fullName ?? 'U').isNotEmpty
                              ? (user?.fullName ?? 'U')[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colors.onPrimaryFixed,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Your Profile',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            '@$username',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.primaryFixed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Friends can find you instantly on DhanWiser using your @$username handle.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Share.share(
                            'Hey! Connect with me on DhanWiser to split expenses easily. Find me using @$username or download DhanWiser: https://dhanwiser.vercel.app',
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: const Text('Share Handle'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: '@$username'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied @$username to clipboard!'),
                            backgroundColor: colors.emerald,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Fast Actions Grid ──
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/create-server'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: colors.primaryFixed.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(IconlyBold.plus, color: colors.primaryFixed, size: 20),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'New Group',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Trip, room, or circle',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _showJoinWithCodeDialog,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: colors.secondary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(IconlyBold.user2, color: colors.secondary, size: 20),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Join via Code',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Enter group code',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── How It Works Explainer ──
          Text(
            'HOW TO SPLIT WITH FRIENDS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          _buildStepRow(
            number: '1',
            title: 'Search any registered user',
            subtitle: 'Type their username or full name in the search bar above to send a direct circle invitation.',
            colors: colors,
          ),
          const SizedBox(height: 10),
          _buildStepRow(
            number: '2',
            title: 'Add to your groups',
            subtitle: 'Assign friends to your trips, flatmate groups, or shared projects.',
            colors: colors,
          ),
          const SizedBox(height: 10),
          _buildStepRow(
            number: '3',
            title: 'Split & settle in real-time',
            subtitle: 'Log shared bills anytime. Balances recalculate instantly with zero manual math.',
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String number,
    required String title,
    required String subtitle,
    required DhanWiserColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.primaryFixed.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: colors.primaryFixed,
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
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: colors.textSecondary,
                    height: 1.35,
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
