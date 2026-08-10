import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../models/settlement_model.dart';
import '../services/settlement_service.dart';
import '../theme/colors.dart';
import 'package:dhanwiser_fixed/theme/text_styles.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

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
          backgroundColor: DhanWiserColors.of(context).mint,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to approve: $e'),
          backgroundColor: DhanWiserColors.of(context).coral,
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
          backgroundColor: DhanWiserColors.of(context).coral,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject: $e'),
          backgroundColor: DhanWiserColors.of(context).coral,
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
              color: DhanWiserColors.of(context).coral, size: 32),
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
            PremiumTextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            PremiumFilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _reject(reasonController.text.trim());
              },
              style: FilledButton.styleFrom(
                backgroundColor: DhanWiserColors.of(context).coral,
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
    return Scaffold(
      backgroundColor: DhanWiserColors.of(context).background,
      body: Stack(
        children: [
          // Blurred Background Context (Simulated)
          Positioned.fill(
            child: Container(
              color: DhanWiserColors.of(context).background,
              // Ideally an image or gradient goes here
            ),
          ),
          // Dimming Overlay
          Positioned.fill(
            child: Container(
              color: DhanWiserColors.of(context).surfaceDim.withValues(alpha: 0.6),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar area
                Align(
                  alignment: Alignment.topLeft,
                  child: PremiumIconButton(
                    padding: const EdgeInsets.all(20),
                    icon: Icon(Icons.arrow_back_rounded,
                        color: DhanWiserColors.of(context).textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Spacer(),
                // Settlement Bottom Sheet
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: DhanWiserColors.of(context).primaryFixed))
                    : _error != null
                        ? _buildErrorView()
                        : _buildSettlementSheet(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: DhanWiserColors.of(context).surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
            color: DhanWiserColors.of(context).surfaceBright.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: DhanWiserColors.of(context).errorContainer.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded,
                color: DhanWiserColors.of(context).error, size: 32),
          ),
          SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: DhanWiserTextStyles.bodyRegular(context)
                .copyWith(color: DhanWiserColors.of(context).textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementSheet() {
    final settlement = _settlement!;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: DhanWiserColors.of(context).surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: DhanWiserColors.of(context).primaryFixed.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, -8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drag Handle Indicator
              Container(
                width: 48,
                height: 6,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: DhanWiserColors.of(context).surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              // Avatar & Header
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DhanWiserColors.of(context).surfaceContainerHigh,
                  border: Border.all(
                      color: DhanWiserColors.of(context).surfaceBright, width: 2),
                ),
                child: Center(
                  child: Text(
                    settlement.payerFullName.isNotEmpty
                        ? settlement.payerFullName[0].toUpperCase()
                        : '?',
                    style: DhanWiserTextStyles.headline2(context)
                        .copyWith(color: DhanWiserColors.of(context).textPrimary),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                settlement.payerFullName,
                style: DhanWiserTextStyles.buttonLarge(context)
                    .copyWith(color: DhanWiserColors.of(context).textPrimary),
              ),
              SizedBox(height: 4),
              Text(
                'is requesting',
                style: DhanWiserTextStyles.caption(context)
                    .copyWith(color: DhanWiserColors.of(context).textSecondary),
              ),
              SizedBox(height: 24),

              // Amount
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 4),
                    child: Text(
                      '₹',
                      style: DhanWiserTextStyles.headline2(context)
                          .copyWith(color: DhanWiserColors.of(context).textSecondary),
                    ),
                  ),
                  Text(
                    settlement.amount.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: DhanWiserColors.of(context).textPrimary,
                        letterSpacing: -1,
                        fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Context Card
              if (settlement.serverName != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DhanWiserColors.of(context).surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: DhanWiserColors.of(context).surfaceContainerHighest),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DhanWiserColors.of(context).surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.flight_takeoff_rounded,
                            color: DhanWiserColors.of(context).primaryFixed, size: 20),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settlement.serverName!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: DhanWiserColors.of(context).textPrimary),
                            ),
                            if (settlement.initiatedAt != null)
                              Text(
                                'Requested recently', // In a real app, calculate time ago
                                style: DhanWiserTextStyles.caption(context)
                                    .copyWith(
                                        color: DhanWiserColors.of(context).textSecondary),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: DhanWiserColors.of(context).textSecondary, size: 20),
                    ],
                  ),
                ),
                SizedBox(height: 24),
              ],

              // Split Details / Notes
              if (settlement.notes != null && settlement.notes!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: DhanWiserColors.of(context).surfaceContainerHighest),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Note',
                        style: DhanWiserTextStyles.caption(context)
                            .copyWith(color: DhanWiserColors.of(context).textSecondary),
                      ),
                      Text(
                        settlement.notes!,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: DhanWiserColors.of(context).textPrimary),
                      ),
                    ],
                  ),
                ),
              ],

              if (settlement.proofImage != null &&
                  settlement.proofImage!.isNotEmpty) ...[
                SizedBox(height: 16),
                _buildProofImage(settlement.proofImage!),
              ],
              const SizedBox(height: 32),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: PremiumElevatedButton(
                  onPressed: _isSubmitting ? null : _approve,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DhanWiserColors.of(context).primaryFixed,
                    foregroundColor: DhanWiserColors.of(context).onPrimaryFixed,
                    elevation: 8,
                    shadowColor:
                        DhanWiserColors.of(context).primaryFixed.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: DhanWiserColors.of(context).onPrimaryFixed))
                      : Text(
                          'Settle Now',
                          style: DhanWiserTextStyles.buttonLarge(context),
                        ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: PremiumOutlinedButton(
                  onPressed: _isSubmitting ? null : _showRejectDialog,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: DhanWiserColors.of(context).surfaceContainerHighest),
                    foregroundColor: DhanWiserColors.of(context).textSecondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text(
                    'Decline Request',
                    style: Theme.of(context).textTheme.titleMedium!,
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProofImage(String proofImage) {
    final imageBytes = _decodeProofImage(proofImage);
    if (imageBytes == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showProofPreview(imageBytes),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DhanWiserColors.of(context).surfaceBright),
          image: DecorationImage(
            image: MemoryImage(imageBytes),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withValues(alpha: 0.3),
          ),
          child: const Center(
            child: Icon(Icons.zoom_in_rounded, color: Colors.white, size: 32),
          ),
        ),
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
                  child: PremiumIconButton(
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
