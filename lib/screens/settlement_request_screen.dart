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
  State<SettlementRequestScreen> createState() =>
      _SettlementRequestScreenState();
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
      final result = await SettlementService.getPendingSettlements();
      final match = result.items.where((s) => s.id == widget.settlementId);

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

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          icon: Icon(Icons.cancel_outlined,
              color: DhanWiserColors.coral, size: 32),
          title: const Text('Reject Settlement'),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason for rejection',
              hintText: 'e.g. I did not receive this payment',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _reject(reasonController.text.trim());
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settlement Request'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.task_alt_rounded,
                            color: cs.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 0,
                    color: isDark
                        ? cs.surfaceContainerHigh
                        : cs.surfaceContainerLowest,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: _buildSettlementCard(cs, isDark),
                    ),
                  ),
                ),
    );
  }

  Widget _buildSettlementCard(ColorScheme cs, bool isDark) {
    final settlement = _settlement!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _userChip(settlement.payerUsername, DhanWiserColors.coral, cs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.arrow_forward_rounded,
                  size: 16, color: cs.onSurfaceVariant),
            ),
            _userChip(settlement.receiverUsername, DhanWiserColors.teal, cs),
            const Spacer(),
            Text(
              '₹${settlement.amount.toStringAsFixed(0)}',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        if (settlement.serverName != null) ...[
          const SizedBox(height: 12),
          Text(
            'Group: ${settlement.serverName}',
            style: GoogleFonts.inter(
                fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 14),
        Text(
          '${settlement.payerFullName} says they paid you this amount. Please approve only if you have actually received the money.',
          style: GoogleFonts.inter(
              fontSize: 14, color: cs.onSurface, height: 1.45),
        ),
        if (settlement.notes != null && settlement.notes!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
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
                Text(
                  'Payment proof / note',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  settlement.notes!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: cs.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (settlement.proofImage != null &&
            settlement.proofImage!.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildProofImage(settlement.proofImage!, cs, isDark),
        ],
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _showRejectDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: DhanWiserColors.coral,
                  side: BorderSide(
                    color: DhanWiserColors.coral.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _isSubmitting ? null : _approve,
                style: FilledButton.styleFrom(
                  backgroundColor: DhanWiserColors.mint,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      DhanWiserColors.mint.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                    : const Text('Approve'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _userChip(String username, Color color, ColorScheme cs) {
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
                  color: cs.onSurface.withValues(alpha: 0.75)),
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
}
