import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class InviteMembersSheet extends StatefulWidget {
  final int serverId;
  final String serverName;

  const InviteMembersSheet({
    super.key,
    required this.serverId,
    required this.serverName,
  });

  static Future<void> show(BuildContext context, int serverId, String serverName) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InviteMembersSheet(
        serverId: serverId,
        serverName: serverName,
      ),
    );
  }

  @override
  State<InviteMembersSheet> createState() => _InviteMembersSheetState();
}

class _InviteMembersSheetState extends State<InviteMembersSheet> {
  // We can track added state here
  final Set<String> _addedUsers = {};

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
      decoration: BoxDecoration(
        color: DhanWiserColors.surfaceContainerHigh.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: DhanWiserColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Text(
                    'Invite to Group',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: DhanWiserColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.serverName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: DhanWiserColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Search Input
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: DhanWiserColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      style: GoogleFonts.inter(color: DhanWiserColors.textPrimary, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Search username or email...',
                        hintStyle: GoogleFonts.inter(color: DhanWiserColors.textDisabled, fontSize: 16),
                        prefixIcon: Icon(Icons.search_rounded, color: DhanWiserColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Quick Share Link Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DhanWiserColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: DhanWiserColors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.link_rounded, color: DhanWiserColors.primaryContainer, size: 20),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invite Link',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: DhanWiserColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'dw.app/j/goa24xpz',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: DhanWiserColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.copy_rounded, color: DhanWiserColors.primaryContainer),
                          style: IconButton.styleFrom(
                            backgroundColor: DhanWiserColors.primaryContainer.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Suggested Contacts List
                  Text(
                    'SUGGESTED',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: DhanWiserColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16),

                  _buildContactItem('Sarah Jenkins', '@sarahj', 'S', DhanWiserColors.primaryFixed),
                  _buildContactItem('Marcus K.', '@marcus_k', 'MK', DhanWiserColors.secondaryContainer),
                  _buildContactItem('Elena V.', '@elenav', 'E', DhanWiserColors.tertiaryFixed),
                  
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Sticky Footer Action
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: DhanWiserColors.surface.withValues(alpha: 0.9),
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: DhanWiserColors.primaryContainer,
                foregroundColor: DhanWiserColors.onPrimaryContainer,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                elevation: 0,
              ),
              child: Text(
                'Done',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String name, String username, String initials, Color color) {
    final isAdded = _addedUsers.contains(username);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isAdded ? DhanWiserColors.surfaceContainer : color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isAdded ? DhanWiserColors.textDisabled : DhanWiserColors.background,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isAdded ? DhanWiserColors.textDisabled : DhanWiserColors.textPrimary,
                  ),
                ),
                Text(
                  username,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isAdded ? DhanWiserColors.textDisabled : DhanWiserColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isAdded)
            Row(
              children: [
                Icon(Icons.check_rounded, color: DhanWiserColors.textDisabled, size: 16),
                SizedBox(width: 4),
                Text(
                  'Added',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DhanWiserColors.textDisabled,
                  ),
                ),
              ],
            )
          else
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _addedUsers.add(username);
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: DhanWiserColors.outlineVariant.withValues(alpha: 0.3)),
                foregroundColor: DhanWiserColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              ),
              child: Text(
                'Add',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
