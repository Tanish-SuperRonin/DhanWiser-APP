import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/settlement_model.dart';
import '../services/settlement_service.dart';
import '../theme/colors.dart';

class SettlementRequestScreen extends StatefulWidget {
  final int settlementId;

  const SettlementRequestScreen({
    super.key,
    required this.settlementId,
  });

  @override
  State<SettlementRequestScreen> createState() => _SettlementRequestScreenState();
}

class _SettlementRequestScreenState extends State<SettlementRequestScreen> {
  SettlementModel? _settlement;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSettlement();
  }

  Future<void> _loadSettlement() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pending = await SettlementService.getPendingSettlements();
      final match = pending.where((s) => s.id == widget.settlementId);

      setState(() {
        _settlement = match.isNotEmpty ? match.first : null;
        _isLoading = false;
        if (_settlement == null) {
          _error = 'This settlement request was already handled.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load settlement request.';
      });
    }
  }

  Future<void> _approve() async {
    setState(() => _isSubmitting = true);
    try {
      await SettlementService.approveSettlement(widget.settlementId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settlement approved!'),
          backgroundColor: DhanWiserColors.mint,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to approve: $e'),
          backgroundColor: DhanWiserColors.coral,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _reject(String? reason) async {
    setState(() => _isSubmitting = true);
    try {
      await SettlementService.rejectSettlement(
        widget.settlementId,
        reason: reason != null && reason.isNotEmpty ? reason : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settlement rejected'),
          backgroundColor: DhanWiserColors.coral,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject: $e'),
          backgroundColor: DhanWiserColors.coral,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark
        ? DhanWiserColors.textPrimaryDark
        : DhanWiserColors.textPrimaryLight;
    final sub = isDark
        ? DhanWiserColors.textSecondaryDark
        : DhanWiserColors.textSecondaryLight;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor:
              isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Reject Settlement',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: text,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            style: GoogleFonts.inter(color: text, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Reason for rejection',
              labelStyle: GoogleFonts.inter(color: sub, fontSize: 14),
              hintText: 'e.g. I did not receive this payment',
              hintStyle: GoogleFonts.inter(
                color: sub.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              filled: true,
              fillColor: isDark
                  ? DhanWiserColors.inputDark
                  : DhanWiserColors.inputLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: sub, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _reject(reasonController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DhanWiserColors.coral,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Reject',
                style:
                    GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final text = isDark
        ? DhanWiserColors.textPrimaryDark
        : DhanWiserColors.textPrimaryLight;
    final sub = isDark
        ? DhanWiserColors.textSecondaryDark
        : DhanWiserColors.textSecondaryLight;
    final surface =
        isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        color: isDark
                            ? DhanWiserColors.surfaceElevatedDark
                            : DhanWiserColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: text, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Settlement Request',
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
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: DhanWiserColors.primary,
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: DhanWiserColors.primary
                                        .withValues(alpha: isDark ? 0.12 : 0.06),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.task_alt_rounded,
                                    color: DhanWiserColors.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: sub,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: isDark ? 0.12 : 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _buildSettlementCard(text, sub, isDark),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementCard(Color text, Color sub, bool isDark) {
    final settlement = _settlement!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _userChip(settlement.payerUsername, DhanWiserColors.coral, isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child:
                  Icon(Icons.arrow_forward_rounded, size: 16, color: sub),
            ),
            _userChip(settlement.receiverUsername, DhanWiserColors.teal, isDark),
            const Spacer(),
            Text(
              '₹${settlement.amount.toStringAsFixed(0)}',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: text,
              ),
            ),
          ],
        ),
        if (settlement.serverName != null) ...[
          const SizedBox(height: 12),
          Text(
            'Group: ${settlement.serverName}',
            style: GoogleFonts.inter(fontSize: 13, color: sub),
          ),
        ],
        const SizedBox(height: 14),
        Text(
          '${settlement.payerFullName} says they paid you this amount. Please approve only if you have actually received the money.',
          style: GoogleFonts.inter(fontSize: 14, color: text, height: 1.45),
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
                Text(
                  'Payment proof / note',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DhanWiserColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  settlement.notes!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: text,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (settlement.proofImage != null && settlement.proofImage!.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildProofImage(settlement.proofImage!, text, sub, isDark),
        ],
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : _showRejectDialog,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: DhanWiserColors.coral.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Reject',
                    style: GoogleFonts.inter(
                      color: DhanWiserColors.coral,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _approve,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DhanWiserColors.mint,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        DhanWiserColors.mint.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Approve',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _userChip(String username, Color color, bool isDark) {
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
              style: GoogleFonts.inter(fontSize: 12, color: text.withValues(alpha: 0.75)),
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
}
