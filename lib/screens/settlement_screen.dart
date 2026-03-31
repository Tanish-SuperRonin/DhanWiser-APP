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
  List<SettlementModel> _pendingSettlements = [];
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
      _pendingSettlements = await SettlementService.getPendingSettlements();
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? DhanWiserColors.surfaceElevatedDark : DhanWiserColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: text, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Settlements',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: text,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Tab bar ──
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
                    Tab(text: 'Pending'),
                    Tab(text: 'History'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Tab Views ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPendingTab(isDark, surface, text, sub),
                  _buildHistoryTab(isDark, surface, text, sub),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTab(bool isDark, Color surface, Color text, Color sub) {
    if (_loadingPending) {
      return Center(child: CircularProgressIndicator(color: DhanWiserColors.primary));
    }

    if (_pendingSettlements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: DhanWiserColors.mint.withValues(alpha: isDark ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.check_circle_rounded, color: DhanWiserColors.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text('All settled!', style: GoogleFonts.inter(
              fontSize: 17, fontWeight: FontWeight.w600, color: text)),
            const SizedBox(height: 4),
            Text('No pending settlements', style: GoogleFonts.inter(
              fontSize: 14, color: sub)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: DhanWiserColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _pendingSettlements.length,
        itemBuilder: (context, index) {
          final s = _pendingSettlements[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payer → Receiver + amount
                Row(
                  children: [
                    _buildUserChip(s.payerUsername, DhanWiserColors.coral, isDark),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 16, color: sub),
                    ),
                    _buildUserChip(s.receiverUsername, DhanWiserColors.teal, isDark),
                    const Spacer(),
                    Text(
                      '₹${s.amount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: text,
                      ),
                    ),
                  ],
                ),

                // ── Proof/Notes section ──
                if (s.notes != null && s.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DhanWiserColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: DhanWiserColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt_long_rounded,
                                size: 14, color: DhanWiserColors.primary),
                            const SizedBox(width: 6),
                            Text('Payment Proof',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: DhanWiserColors.primary,
                                )),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.notes!,
                          style: GoogleFonts.inter(fontSize: 13, color: text, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Server name ──
                if (s.proofImage != null && s.proofImage!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildProofImage(s.proofImage!, text, sub, isDark),
                ],
                if (s.serverName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Group: ${s.serverName}',
                    style: GoogleFonts.inter(fontSize: 12, color: sub),
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
                        color: DhanWiserColors.warning.withValues(alpha: isDark ? 0.12 : 0.06),
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
                        child: SizedBox(
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () => _showRejectDialog(s),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: DhanWiserColors.coral.withValues(alpha: 0.3)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Reject', style: GoogleFonts.inter(
                              color: DhanWiserColors.coral, fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => _showApproveDialog(s),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DhanWiserColors.mint,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Approve', style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Approve confirmation dialog ──
  void _showApproveDialog(SettlementModel settlement) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final sub = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Confirm Payment',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: text, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${settlement.payerFullName} says they paid you ₹${settlement.amount.toStringAsFixed(0)}.',
                style: GoogleFonts.inter(fontSize: 14, color: text, height: 1.5),
              ),
              if (settlement.notes != null && settlement.notes!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DhanWiserColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DhanWiserColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Their proof:',
                          style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600, color: DhanWiserColors.primary)),
                      const SizedBox(height: 4),
                      Text(settlement.notes!,
                          style: GoogleFonts.inter(fontSize: 13, color: text, height: 1.4)),
                    ],
                  ),
                ),
              ],
              if (settlement.proofImage != null &&
                  settlement.proofImage!.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildProofImage(settlement.proofImage!, text, sub, isDark),
              ],
              const SizedBox(height: 14),
              Text(
                'Did you actually receive this payment? Only approve if you can confirm.',
                style: GoogleFonts.inter(fontSize: 13, color: sub, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: sub, fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _handleApprove(settlement.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DhanWiserColors.mint,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Yes, I Received It',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        );
      },
    );
  }

  // ── Reject dialog with reason ──
  void _showRejectDialog(SettlementModel settlement) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final sub = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Reject Settlement',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: text, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${settlement.payerFullName} claims to have paid ₹${settlement.amount.toStringAsFixed(0)}.',
                style: GoogleFonts.inter(fontSize: 14, color: text, height: 1.5),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: GoogleFonts.inter(color: text, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Reason for rejection',
                  labelStyle: GoogleFonts.inter(color: sub, fontSize: 14),
                  hintText: 'e.g. I didn\'t receive this payment',
                  hintStyle: GoogleFonts.inter(color: sub.withValues(alpha: 0.5), fontSize: 13),
                  filled: true,
                  fillColor: isDark ? DhanWiserColors.inputDark : DhanWiserColors.inputLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: sub, fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _handleReject(settlement.id, reason: reasonController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DhanWiserColors.coral,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Reject',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryTab(bool isDark, Color surface, Color text, Color sub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: DhanWiserColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.history_rounded, color: DhanWiserColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Settlement history', style: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w600, color: text)),
          const SizedBox(height: 4),
          Text('Select a group to view history', style: GoogleFonts.inter(
            fontSize: 14, color: sub)),
        ],
      ),
    );
  }

  Widget _buildUserChip(String username, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.06),
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

  Widget _buildProofImage(String proofImage, Color text, Color sub, bool isDark) {
    final imageBytes = _decodeProofImage(proofImage);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DhanWiserColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DhanWiserColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image_outlined, size: 16, color: DhanWiserColors.primary),
              const SizedBox(width: 6),
              Text(
                'Payment screenshot',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DhanWiserColors.primary,
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
              style: GoogleFonts.inter(fontSize: 13, color: sub),
            ),
          if (imageBytes != null) ...[
            const SizedBox(height: 8),
            Text(
              'Tap the screenshot to open it full screen before approving.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: text.withValues(alpha: 0.75),
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
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
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
            content: Text('Settlement approved!'),
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
            content: Text('Settlement rejected'),
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
