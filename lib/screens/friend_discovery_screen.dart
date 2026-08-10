import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../providers/server_provider.dart';
import 'package:dhanwiser_fixed/theme/text_styles.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

class FriendDiscoveryScreen extends StatefulWidget {
  final bool isRootTab;
  const FriendDiscoveryScreen({super.key, this.isRootTab = false});

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
          backgroundColor: DhanWiserColors.of(context).coral,
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
              SizedBox(height: 8),
              Text(
                'Invite ${user.fullName}',
                style: DhanWiserTextStyles.buttonLarge(context)
                    .copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Select a group to invite @${user.username} to:',
                style: DhanWiserTextStyles.caption(context)
                    .copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ...servers.map((server) {
                final initial =
                    server.name.isNotEmpty ? server.name[0].toUpperCase() : 'G';
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
                        style: DhanWiserTextStyles.buttonLarge(context)
                            .copyWith(color: cs.primary),
                      ),
                    ),
                  ),
                  title: Text(
                    server.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: cs.onSurface),
                  ),
                  subtitle: Text(
                    '${server.memberCount} members',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: cs.onSurfaceVariant),
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
              backgroundColor: DhanWiserColors.of(context).mint,
            ),
          );
        } else {
          setState(() => _inviteStates[user.id] = 'error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(serverProv.error ?? 'Failed to invite'),
              backgroundColor: DhanWiserColors.of(context).coral,
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
            backgroundColor: DhanWiserColors.of(context).coral,
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
    return Scaffold(
      backgroundColor: DhanWiserColors.of(context).background,
      appBar: AppBar(
        backgroundColor: DhanWiserColors.of(context).background.withValues(alpha: 0.8),
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: widget.isRootTab ? null : PremiumIconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: DhanWiserColors.of(context).textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Discover Friends',
          style: DhanWiserTextStyles.buttonLarge(context)
              .copyWith(color: DhanWiserColors.of(context).primary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: DhanWiserColors.of(context).surfaceContainer.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              style: DhanWiserTextStyles.bodyRegular(context)
                  .copyWith(color: DhanWiserColors.of(context).primary),
              decoration: InputDecoration(
                hintText: 'Search by name, @username or email...',
                hintStyle: DhanWiserTextStyles.bodyRegular(context)
                    .copyWith(color: DhanWiserColors.of(context).textDisabled),
                prefixIcon: Icon(Icons.search_rounded,
                    color: DhanWiserColors.of(context).textDisabled),
                filled: true,
                fillColor: DhanWiserColors.of(context).surfaceContainerLow,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      BorderSide(color: DhanWiserColors.of(context).surfaceContainer),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      BorderSide(color: DhanWiserColors.of(context).surfaceContainer),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                      color:
                          DhanWiserColors.of(context).primaryFixed.withValues(alpha: 0.5)),
                ),
              ),
              onChanged: (q) {
                if (q.length >= 2) _performSearch(q);
              },
              onSubmitted: _performSearch,
            ),
          ),

          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildInviteButton(PublicUser user) {
    final state = _inviteStates[user.id];

    if (state == 'loading') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: DhanWiserColors.of(context).surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
              color: DhanWiserColors.of(context).primary, strokeWidth: 2),
        ),
      );
    }

    if (state == 'sent') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: DhanWiserColors.of(context).surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: DhanWiserColors.of(context).surfaceContainer),
        ),
        child: Text(
          'Requested',
          style: DhanWiserTextStyles.overline(context).copyWith(
            color: DhanWiserColors.of(context).textSecondary,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showInviteDialog(user),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: DhanWiserColors.of(context).primaryFixed,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Invite',
          style: DhanWiserTextStyles.overline(context).copyWith(
            color: DhanWiserColors.of(context).onPrimaryFixed,
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return Center(
          child: CircularProgressIndicator(color: DhanWiserColors.of(context).primary));
    }

    if (_searchError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded,
                color: DhanWiserColors.of(context).error, size: 32),
            SizedBox(height: 12),
            Text(_searchError!,
                style: DhanWiserTextStyles.caption(context)
                    .copyWith(color: DhanWiserColors.of(context).textSecondary)),
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
                color: DhanWiserColors.of(context).surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.search_off_rounded,
                  color: DhanWiserColors.of(context).textDisabled, size: 28),
            ),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: DhanWiserTextStyles.buttonLarge(context)
                  .copyWith(color: DhanWiserColors.of(context).textPrimary),
            ),
            SizedBox(height: 4),
            Text(
              'Try a different search term',
              style: DhanWiserTextStyles.caption(context)
                  .copyWith(color: DhanWiserColors.of(context).textDisabled),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      // Could show suggested users here if we had them
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Search Results',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: DhanWiserColors.of(context).textSecondary),
          ),
        ),
        SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final user = _searchResults[index];
              final initial = user.fullName.isNotEmpty
                  ? user.fullName[0].toUpperCase()
                  : '?';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DhanWiserColors.of(context).card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DhanWiserColors.of(context).surfaceContainer),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: DhanWiserColors.of(context).surfaceVariant,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: DhanWiserColors.of(context).surfaceBright),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: DhanWiserTextStyles.buttonLarge(context)
                              .copyWith(color: DhanWiserColors.of(context).textSecondary),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: DhanWiserColors.of(context).primary),
                          ),
                          Text(
                            '@${user.username}',
                            style: DhanWiserTextStyles.caption(context)
                                .copyWith(color: DhanWiserColors.of(context).textSecondary),
                          ),
                        ],
                      ),
                    ),
                    _buildInviteButton(user),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
