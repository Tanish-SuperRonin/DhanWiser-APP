import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/auth_provider.dart';
import '../services/settlement_service.dart';
import '../models/settlement_model.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({super.key});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SettlementModel> _incomingSettlements = [];
  List<SettlementModel> _outgoingSettlements = [];
  bool _loadingPending = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        SettlementService.getPendingSettlements(),
        SettlementService.getOutgoingSettlements(),
      ]);
      _incomingSettlements = results[0].items;
      _outgoingSettlements = results[1].items;
    } catch (_) {}
    _loadingPending = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settlements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
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
                  Tab(text: 'Pending'),
                  Tab(text: 'History'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(cs, isDark),
          _buildHistoryTab(cs, isDark),
        ],
      ),
    );
  }

  Widget _buildPendingTab(ColorScheme cs, bool isDark) {
    if (_loadingPending) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    final hasIncoming = _incomingSettlements.isNotEmpty;
    final hasOutgoing = _outgoingSettlements.isNotEmpty;

    if (!hasIncoming && !hasOutgoing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.check_circle_rounded,
                  color: cs.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'All settled!',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No pending settlements',
              style: GoogleFonts.inter(
                  fontSize: 14, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    // Combine both lists with section headers
    final allItems = <_PendingListItem>[];
    if (hasIncoming) {
      allItems.add(
          _PendingListItem(isHeader: true, headerTitle: 'Awaiting Your Approval'));
      allItems.addAll(
          _incomingSettlements.map((s) => _PendingListItem(settlement: s)));
    }
    if (hasOutgoing) {
      allItems
          .add(_PendingListItem(isHeader: true, headerTitle: 'Sent by You'));
      allItems.addAll(
          _outgoingSettlements.map((s) => _PendingListItem(settlement: s)));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: cs.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allItems.length,
        itemBuilder: (context, index) {
          final item = allItems[index];
          if (item.isHeader) {
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 10, left: 4),
              child: Text(
                item.headerTitle!.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
            );
          }
          final s = item.settlement!;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            color:
                isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payer → Receiver + amount
                  Row(
                    children: [
                      _buildUserChip(s.payerUsername, DhanWiserColors.coral, cs),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 16, color: cs.onSurfaceVariant),
                      ),
                      _buildUserChip(
                          s.receiverUsername, DhanWiserColors.teal, cs),
                      const Spacer(),
                      Text(
                        '₹${s.amount.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),

                  // ── Proof/Notes section ──
                  if (s.notes != null && s.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildProofNotesContainer(s.notes!, cs, isDark),
                  ],

                  // ── Proof image ──
                  if (s.proofImage != null && s.proofImage!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildProofImage(s.proofImage!, cs, isDark),
                  ],
                  if (s.serverName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Group: ${s.serverName}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // ── Actions: only show to receiver ──
                  Builder(builder: (ctx) {
                    final auth = Provider.of<AuthProvider>(ctx, listen: false);
                    final currentUser = auth.currentUser;
                    final isReceiver = currentUser != null &&
                        (currentUser.username == s.receiverUsername ||
                            currentUser.id == s.receiverId);

                    if (!isReceiver) {
                      // Payer sees a waiting badge
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: DhanWiserColors.warning
                              .withValues(alpha: isDark ? 0.16 : 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Waiting for ${s.receiverUsername} to approve',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: DhanWiserColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showRejectDialog(s),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DhanWiserColors.coral,
                              side: BorderSide(
                                color: DhanWiserColors.coral
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _showApproveDialog(s),
                            style: FilledButton.styleFrom(
                              backgroundColor: DhanWiserColors.mint,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Approve'),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProofNotesContainer(
      String notes, ColorScheme cs, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: isDark ? 0.2 : 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 14, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'Payment Proof',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            notes,
            style: GoogleFonts.inter(
                fontSize: 13, color: cs.onSurface, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ── Approve confirmation dialog ──
  void _showApproveDialog(SettlementModel settlement) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          icon: Icon(Icons.check_circle_outline_rounded,
              color: DhanWiserColors.mint, size: 32),
          title: const Text('Confirm Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${settlement.payerFullName} says they paid you ₹${settlement.amount.toStringAsFixed(0)}.',
              ),
              if (settlement.notes != null &&
                  settlement.notes!.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildProofNotesContainer(settlement.notes!, cs, isDark),
              ],
              if (settlement.proofImage != null &&
                  settlement.proofImage!.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildProofImage(settlement.proofImage!, cs, isDark),
              ],
              const SizedBox(height: 14),
              Text(
                'Did you actually receive this payment? Only approve if you can confirm.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: cs.onSurfaceVariant, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _handleApprove(settlement.id);
              },
              style: FilledButton.styleFrom(
                backgroundColor: DhanWiserColors.mint,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, I Received It'),
            ),
          ],
        );
      },
    );
  }

  // ── Reject dialog with reason ──
  void _showRejectDialog(SettlementModel settlement) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          icon: Icon(Icons.cancel_outlined,
              color: DhanWiserColors.coral, size: 32),
          title: const Text('Reject Settlement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${settlement.payerFullName} claims to have paid ₹${settlement.amount.toStringAsFixed(0)}.',
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason for rejection',
                  hintText: 'e.g. I didn\'t receive this payment',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _handleReject(settlement.id,
                    reason: reasonController.text.trim());
              },
              style: FilledButton.styleFrom(
                backgroundColor: DhanWiserColors.coral,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryTab(ColorScheme cs, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.history_rounded, color: cs.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Settlement history',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a group to view history',
            style:
                GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildUserChip(String username, Color color, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        username,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProofImage(
      String proofImage, ColorScheme cs, bool isDark) {
    final imageBytes = _decodeProofImage(proofImage);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: isDark ? 0.2 : 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image_outlined, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'Payment screenshot',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (imageBytes != null)
            GestureDetector(
              onTap: () => _showProofPreview(imageBytes),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  imageBytes,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Text(
              'This screenshot could not be displayed.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: cs.onSurfaceVariant),
            ),
          if (imageBytes != null) ...[
            const SizedBox(height: 8),
            Text(
              'Tap the screenshot to open it full screen before approving.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Uint8List? _decodeProofImage(String proofImage) {
    try {
      final parts = proofImage.split(',');
      if (parts.length < 2) return null;
      return base64Decode(parts.last);
    } catch (_) {
      return null;
    }
  }

  void _showProofPreview(Uint8List imageBytes) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: SafeArea(
                  child: IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon:
                        const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleApprove(int id) async {
    try {
      await SettlementService.approveSettlement(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settlement approved!'),
            backgroundColor: DhanWiserColors.mint,
          ),
        );
      }
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve: $e'),
            backgroundColor: DhanWiserColors.coral,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(int id, {String? reason}) async {
    try {
      await SettlementService.rejectSettlement(id,
          reason: (reason != null && reason.isNotEmpty) ? reason : null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settlement rejected'),
            backgroundColor: DhanWiserColors.coral,
          ),
        );
      }
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject: $e'),
            backgroundColor: DhanWiserColors.coral,
          ),
        );
      }
    }
  }
}

class _PendingListItem {
  final bool isHeader;
  final String? headerTitle;
  final SettlementModel? settlement;

  _PendingListItem({this.isHeader = false, this.headerTitle, this.settlement});
}
