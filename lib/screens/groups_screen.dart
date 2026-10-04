import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/server_model.dart';
import '../providers/server_provider.dart';
import '../theme/colors.dart';
import '../theme/design_tokens.dart';
import '../theme/iconly_icons.dart';
import '../widgets/dhanwiser_ui.dart';
import 'join_group_screen.dart';

/// Collaborative hub for shared spaces, friend discovery, and instant group joining.
class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ServerProvider>().fetchServers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openGroup(ServerModel server) {
    Navigator.pushNamed(
      context,
      '/server-detail',
      arguments: {
        'serverId': server.id,
        'serverName': server.name,
        'members': '${server.memberCount} members',
      },
    );
  }

  void _showJoinWithCodeDialog() {
    final controller = TextEditingController();
    final colors = DhanWiserColors.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primaryFixed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(IconlyBold.ticket, color: colors.primaryFixed, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Join via Code',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the group ID or paste an invite link shared by your friend:',
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
                  content: const Text('Could not find a valid group ID in your input'),
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

  void _showGroupInviteSheet(ServerModel server) {
    final colors = DhanWiserColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.primaryFixed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(IconlyBold.user2, color: colors.primaryFixed, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invite to ${server.name}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            'Group Code: #${server.id}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primaryFixed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(IconlyBold.addUser, color: colors.primaryFixed, size: 20),
                  ),
                  title: Text(
                    'Search & Invite Friends',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Find friends on DhanWiser by @username or email',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                  trailing: Icon(IconlyLight.arrowRight2, size: 16, color: colors.textSecondary),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(
                      context,
                      '/friend-discovery',
                      arguments: {
                        'serverId': server.id,
                        'serverName': server.name,
                      },
                    );
                  },
                ),
                const Divider(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.emerald.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.share_rounded, color: colors.emerald, size: 20),
                  ),
                  title: Text(
                    'Share Invite Link / Code',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Share via WhatsApp, Telegram, or Messages',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                  trailing: Icon(IconlyLight.arrowRight2, size: 16, color: colors.textSecondary),
                  onTap: () {
                    Navigator.pop(ctx);
                    Share.share(
                      'Join my "${server.name}" group on DhanWiser to split expenses easily!\n'
                      'Use group code: ${server.id}\n'
                      'Download DhanWiser: https://dhanwiser.vercel.app/join/${server.id}',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = DhanWiserColors.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Consumer<ServerProvider>(
          builder: (context, provider, _) {
            final visibleServers = provider.servers
                .where((server) =>
                    server.name.toLowerCase().contains(_query.toLowerCase()))
                .toList();
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOUR SPACES',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: colors.textSecondary,
                                  letterSpacing: 1.4,
                                )),
                        const SizedBox(height: 4),
                        Text('Groups',
                            style: Theme.of(context).textTheme.displaySmall),
                        const SizedBox(height: 8),
                        Text(
                          'Shared plans, bills, and balances — all together.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        _buildSummary(provider.servers.length, colors),
                        const SizedBox(height: 14),
                        // ── Fast Actions Row: Find Friends & Join via Code ──
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionPill(
                                icon: IconlyBold.addUser,
                                label: 'Find Friends',
                                subtitle: 'Search by handle',
                                color: colors.primaryFixed,
                                onTap: () => Navigator.pushNamed(context, '/friend-discovery'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionPill(
                                icon: IconlyBold.ticket,
                                label: 'Join via Code',
                                subtitle: 'Enter invite code',
                                color: colors.secondary,
                                onTap: _showJoinWithCodeDialog,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search your groups',
                            prefixIcon: const Icon(IconlyLight.search),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Your groups',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                  context, '/create-server'),
                              icon: const Icon(IconlyBold.plus, size: 18),
                              label: const Text('New group'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (provider.isLoading && provider.servers.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) => Container(
                        height: 88,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh,
                          borderRadius: DhanWiserTokens.radiusMedium,
                        ),
                      ),
                    ),
                  )
                else if (visibleServers.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                    sliver: SliverToBoxAdapter(
                      child: _buildEmptyState(colors),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                    sliver: SliverList.separated(
                      itemCount: visibleServers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _GroupTile(
                        server: visibleServers[index],
                        color: colors
                            .groupColors[index % colors.groupColors.length],
                        onTap: () => _openGroup(visibleServers[index]),
                        onInvite: () => _showGroupInviteSheet(visibleServers[index]),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colors = DhanWiserColors.of(context);
    return DhanWiserSurface(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: DhanWiserTokens.radiusMedium,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(int count, DhanWiserColors colors) {
    return DhanWiserSurface(
      padding: const EdgeInsets.all(18),
      radius: DhanWiserTokens.radiusLarge,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(IconlyBold.user2, color: colors.secondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count active ${count == 1 ? 'group' : 'groups'}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text('Keep shared spending in sync',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        )),
              ],
            ),
          ),
          Icon(IconlyLight.arrowRight2,
              size: 18, color: colors.textDisabled),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DhanWiserColors colors) {
    return DhanWiserSurface(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      radius: DhanWiserTokens.radiusLarge,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colors.primaryFixed.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(IconlyBold.addUser,
                color: colors.textPrimary, size: 27),
          ),
          const SizedBox(height: 16),
          Text(_query.isEmpty ? 'Start a group' : 'No matching groups',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            _query.isEmpty
                ? 'Bring your people together and make shared expenses easy to track.'
                : 'No group found named "$_query". Would you like to search for friends instead?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          if (_query.isNotEmpty)
            FilledButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/friend-discovery',
                  arguments: {'query': _query},
                );
              },
              icon: const Icon(IconlyBold.addUser, size: 18),
              label: Text('Search for "$_query" in Friends'),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/create-server'),
                  icon: const Icon(IconlyBold.plus),
                  label: const Text('Create a group'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/friend-discovery'),
                  icon: const Icon(IconlyBold.addUser),
                  label: const Text('Find Friends'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.server,
    required this.color,
    required this.onTap,
    required this.onInvite,
  });

  final ServerModel server;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final colors = DhanWiserColors.of(context);
    return DhanWiserSurface(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      radius: DhanWiserTokens.radiusMedium,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(IconlyBold.user2, color: color, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(server.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${server.memberCount} members',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        )),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Invite friends to ${server.name}',
            onPressed: onInvite,
            icon: Icon(IconlyLight.addUser, size: 20, color: colors.primaryFixed),
          ),
          Icon(IconlyLight.arrowRight2,
              color: colors.textDisabled, size: 20),
        ],
      ),
    );
  }
}
