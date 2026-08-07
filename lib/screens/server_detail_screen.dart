import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../widgets/bouncing_button.dart';
import '../widgets/shimmer_loading.dart';
import '../utils/json_parsers.dart';
import '../providers/server_provider.dart';
import '../providers/auth_provider.dart';
import '../services/expense_service.dart';
import '../services/settlement_service.dart';
import '../models/expense_model.dart';
import '../models/balance_model.dart';
import '../widgets/swipeable_expense_row.dart';

class ServerDetailScreen extends StatefulWidget {
  final int serverId;
  final String serverName;
  final String members;
  final String imageUrl;

  const ServerDetailScreen({
    super.key,
    this.serverId = 0,
    this.serverName = 'Server',
    this.members = '0 members',
    this.imageUrl = '',
  });

  @override
  State<ServerDetailScreen> createState() => _ServerDetailScreenState();
}

class _ServerDetailScreenState extends State<ServerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ExpenseModel> _expenses = [];
  List<BalanceModel> _balances = [];
  List<SuggestedSettlement> _suggestions = [];
  bool _loadingExpenses = true;
  bool _loadingBalances = true;

  // Pagination state for expenses
  int _expensePage = 1;
  bool _hasMoreExpenses = false;
  bool _loadingMoreExpenses = false;
  static const int _expensePageSize = 20;

  // Scroll controller for infinite scroll
  final ScrollController _expenseScrollController = ScrollController();

  // Lazy tab loading: track which tabs have been loaded
  final Set<int> _loadedTabs = {0}; // Tab 0 (expenses) loads by default

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _expenseScrollController.addListener(_onExpenseScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _expenseScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Lazy tab loading: only fetch data for a tab when user first visits it.
  void _onTabChanged() {
    final index = _tabController.index;
    if (!_loadedTabs.contains(index)) {
      _loadedTabs.add(index);
      if (index == 1) {
        // Balances tab
        _loadBalances();
      }
      // Tab 2 (Members) data comes from server details which is already loaded
    }
  }

  /// Infinite scroll: load more expenses when near the bottom.
  void _onExpenseScroll() {
    if (_expenseScrollController.position.pixels >=
        _expenseScrollController.position.maxScrollExtent - 200) {
      _loadMoreExpenses();
    }
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _loadingExpenses = true;
        _loadingBalances = true;
      });
    } else {
      _loadingExpenses = true;
      _loadingBalances = true;
    }

    final serverProvider = Provider.of<ServerProvider>(context, listen: false);
    await serverProvider.fetchServerDetails(widget.serverId);

    // Load first page of expenses
    _expensePage = 1;
    try {
      final result = await ExpenseService.getServerExpenses(
        widget.serverId,
        page: 1,
        limit: _expensePageSize,
      );
      _expenses = result.items;
      _hasMoreExpenses = result.hasMore;
      _expensePage = 1;
    } catch (_) {
      _expenses = [];
      _hasMoreExpenses = false;
    }
    _loadingExpenses = false;

    // Load balances only if that tab has been visited, otherwise defer
    if (_loadedTabs.contains(1)) {
      await _loadBalances();
    } else {
      _loadingBalances = false;
    }

    if (mounted) setState(() {});
  }

  /// Load balances (called lazily when balance tab is first visited).
  Future<void> _loadBalances() async {
    if (mounted) setState(() => _loadingBalances = true);
    try {
      final balanceData = await ExpenseService.getServerBalances(widget.serverId);
      _balances = balanceData['balances'] as List<BalanceModel>;
      _suggestions = balanceData['suggestedSettlements'] as List<SuggestedSettlement>;
    } catch (_) {
      _balances = [];
      _suggestions = [];
    }
    _loadingBalances = false;
    if (mounted) setState(() {});
  }

  /// Load the next page of expenses (infinite scroll).
  Future<void> _loadMoreExpenses() async {
    if (_loadingMoreExpenses || !_hasMoreExpenses) return;
    _loadingMoreExpenses = true;
    if (mounted) setState(() {});

    try {
      final result = await ExpenseService.getServerExpenses(
        widget.serverId,
        page: _expensePage + 1,
        limit: _expensePageSize,
      );
      _expenses.addAll(result.items);
      _expensePage++;
      _hasMoreExpenses = result.hasMore;
    } catch (_) {
      // Keep existing data, just stop loading more
      _hasMoreExpenses = false;
    }
    _loadingMoreExpenses = false;
    if (mounted) setState(() {});
  }

  Future<void> _showReminderSettingsSheet() async {
    final serverProv = Provider.of<ServerProvider>(context, listen: false);
    final settings = await serverProv.getReminderSettings(widget.serverId);

    if (!mounted) return;

    if (settings == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(serverProv.error ?? 'Failed to load reminder settings'),
          backgroundColor: DhanWiserColors.coral,
        ),
      );
      return;
    }

    final cs = Theme.of(context).colorScheme;

    bool reminderEnabled = settings['reminderEnabled'] ?? true;
    double intervalDays =
        parseDoubleValue(settings['reminderIntervalDays'], fallback: 7)
            .toDouble();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20, 8, 20,
                MediaQuery.of(ctx).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Payment Reminders',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Automatic in-app reminders are on by default every 7 days.',
                    style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant, height: 1.45),
                  ),
                  const SizedBox(height: 18),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Enable automatic reminders',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                    value: reminderEnabled,
                    onChanged: isSaving ? null : (v) => setSheetState(() => reminderEnabled = v),
                  ),
                  if (reminderEnabled) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Reminder interval: ${intervalDays.round()} day${intervalDays.round() == 1 ? '' : 's'}',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
                    ),
                    Slider(
                      value: intervalDays, min: 1, max: 30, divisions: 29,
                      label: '${intervalDays.round()} days',
                      onChanged: isSaving ? null : (v) => setSheetState(() => intervalDays = v),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity, height: 48,
                    child: FilledButton(
                      onPressed: isSaving ? null : () async {
                        setSheetState(() => isSaving = true);
                        final navigator = Navigator.of(ctx);
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await serverProv.updateReminderSettings(
                          serverId: widget.serverId,
                          reminderEnabled: reminderEnabled,
                          reminderIntervalDays: intervalDays.round(),
                        );
                        if (!mounted) return;
                        navigator.pop();
                        messenger.showSnackBar(SnackBar(
                          content: Text(success ? 'Reminder settings updated' : (serverProv.error ?? 'Failed')),
                          backgroundColor: success ? DhanWiserColors.mint : DhanWiserColors.coral,
                        ));
                      },
                      child: isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Save Reminder Settings', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteOrLeave({
    required bool canDelete,
    required String groupName,
  }) async {
    final serverProv = Provider.of<ServerProvider>(context, listen: false);
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              icon: Icon(canDelete ? Icons.delete_outline_rounded : Icons.exit_to_app_rounded, color: DhanWiserColors.coral, size: 32),
              title: Text(canDelete ? 'Delete Group' : 'Leave Group'),
              content: Text(canDelete
                  ? 'Delete "$groupName"? This removes the group for everyone and cannot be undone.'
                  : 'Leave "$groupName"? You can join again only if someone invites you back.'),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSubmitting ? null : () async {
                    setDialogState(() => isSubmitting = true);
                    final dialogNavigator = Navigator.of(ctx);
                    final messenger = ScaffoldMessenger.of(context);
                    final pageNavigator = Navigator.of(context);
                    final success = canDelete
                        ? await serverProv.deleteServer(widget.serverId)
                        : await serverProv.leaveServer(widget.serverId);
                    if (!mounted) return;
                    dialogNavigator.pop();
                    messenger.showSnackBar(SnackBar(
                      content: Text(success ? (canDelete ? 'Group deleted' : 'You left the group') : (serverProv.error ?? 'Unable to update group')),
                      backgroundColor: success ? DhanWiserColors.mint : DhanWiserColors.coral,
                    ));
                    if (success && mounted) pageNavigator.pop(true);
                  },
                  style: FilledButton.styleFrom(backgroundColor: DhanWiserColors.coral, foregroundColor: Colors.white),
                  child: isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(canDelete ? 'Delete' : 'Leave'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSettleUpDialog(SuggestedSettlement suggestion) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final sub = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;
    final transactionIdController = TextEditingController();
    final notesController = TextEditingController();
    bool isSending = false;
    Uint8List? proofBytes;
    String? proofImage;
    String? proofFileName;

    // Check if current user is the payer
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = auth.currentUser?.id;
    final fromUserId = suggestion.from['userId'] ?? suggestion.from['id'];

    if (currentUserId != fromUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only ${suggestion.fromUsername} can initiate this settlement'),
          backgroundColor: DhanWiserColors.coral,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20, 16, 20,
                MediaQuery.of(ctx).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? DhanWiserColors.gray600 : DhanWiserColors.gray300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Settle Up',
                    style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w700, color: text),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You owe ₹${suggestion.amount.toStringAsFixed(0)} to ${suggestion.toUsername}',
                    style: GoogleFonts.inter(fontSize: 15, color: sub),
                  ),
                  const SizedBox(height: 20),

                  // Transaction ID
                  Text('Transaction ID / UPI Ref *',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: sub)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: transactionIdController,
                    style: GoogleFonts.inter(color: text, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'e.g. UPI123456789',
                      hintStyle: GoogleFonts.inter(color: sub.withValues(alpha: 0.4), fontSize: 14),
                      filled: true,
                      fillColor: isDark ? DhanWiserColors.inputDark : DhanWiserColors.inputLight,
                      prefixIcon: Icon(Icons.receipt_long_rounded, color: sub, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Notes
                  Text('Payment details (optional)',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: sub)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    style: GoogleFonts.inter(color: text, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'e.g. Paid via Google Pay, screenshot attached',
                      hintStyle: GoogleFonts.inter(color: sub.withValues(alpha: 0.4), fontSize: 13),
                      filled: true,
                      fillColor: isDark ? DhanWiserColors.inputDark : DhanWiserColors.inputLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Screenshot proof (optional)',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: sub)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: isSending
                        ? null
                        : () async {
                            final picked = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                              withData: true,
                            );
                            final file = picked?.files.single;
                            if (file == null || file.bytes == null) {
                              return;
                            }
                            if (file.bytes!.length > 2 * 1024 * 1024) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Please choose an image smaller than 2 MB.',
                                  ),
                                  backgroundColor: DhanWiserColors.coral,
                                ),
                              );
                              return;
                            }

                            final extension = (file.extension ?? 'png').toLowerCase();
                            final mimeType = extension == 'jpg' || extension == 'jpeg'
                                ? 'image/jpeg'
                                : extension == 'webp'
                                    ? 'image/webp'
                                    : 'image/png';

                            setSheetState(() {
                              proofBytes = file.bytes;
                              proofFileName = file.name;
                              proofImage =
                                  'data:$mimeType;base64,${base64Encode(file.bytes!)}';
                            });
                          },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? DhanWiserColors.inputDark : DhanWiserColors.inputLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: proofBytes != null
                              ? DhanWiserColors.primary.withValues(alpha: 0.35)
                              : Colors.transparent,
                        ),
                      ),
                      child: proofBytes == null
                          ? Row(
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, color: sub, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Attach payment screenshot',
                                    style: GoogleFonts.inter(color: sub, fontSize: 14),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    proofBytes!,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.image_outlined,
                                        color: DhanWiserColors.primary, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        proofFileName ?? 'Screenshot attached',
                                        style: GoogleFonts.inter(
                                          color: text,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: isSending
                                          ? null
                                          : () {
                                              setSheetState(() {
                                                proofBytes = null;
                                                proofImage = null;
                                                proofFileName = null;
                                              });
                                            },
                                      child: Text(
                                        'Remove',
                                        style: GoogleFonts.inter(
                                          color: DhanWiserColors.coral,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSending ? null : () async {
                        final txnId = transactionIdController.text.trim();
                        if (txnId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter a transaction ID'),
                              backgroundColor: DhanWiserColors.coral,
                            ),
                          );
                          return;
                        }
                        setSheetState(() => isSending = true);

                        // Combine transaction ID and notes into proof string
                        String proof = 'Transaction ID: $txnId';
                        final notes = notesController.text.trim();
                        if (notes.isNotEmpty) proof += '\n$notes';

                        // Capture navigator/messenger before async gap
                        final sheetNavigator = Navigator.of(ctx);
                        final messenger = ScaffoldMessenger.of(context);

                        try {
                          final toUserId = suggestion.to['userId'] ?? suggestion.to['id'];
                          await SettlementService.initiateSettlement(
                            serverId: widget.serverId,
                            receiverId: toUserId,
                            amount: suggestion.amount,
                            notes: proof,
                            proofImage: proofImage,
                          );
                          if (mounted) {
                            sheetNavigator.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Settlement sent! Waiting for ${suggestion.toUsername} to approve.'),
                                backgroundColor: DhanWiserColors.mint,
                              ),
                            );
                            await _loadData();
                          }
                        } catch (e) {
                          setSheetState(() => isSending = false);
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Failed: $e'),
                                backgroundColor: DhanWiserColors.coral,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DhanWiserColors.mint,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        disabledBackgroundColor: DhanWiserColors.mint.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSending
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text('Send Settlement Request',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = cs.surface;
    final surface = isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest;
    final text = cs.onSurface;
    final sub = cs.onSurfaceVariant;

    // Deterministic gradient from server name
    final grads = [
      [const Color(0xFF4ECDC4), const Color(0xFF7EDDD6)],
      [const Color(0xFF95E1D3), const Color(0xFFA8E6CF)],
      [const Color(0xFFFFB5A7), const Color(0xFFFFCDBD)],
      [const Color(0xFFFFD97D), const Color(0xFFFFE5A0)],
    ];
    final grad = grads[widget.serverName.hashCode.abs() % grads.length];

    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: bg,
              elevation: 0,
              pinned: true,
              expandedHeight: 200,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        '/add-expense',
                        arguments: {'serverId': widget.serverId},
                      );
                      await _loadData();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            'Expense',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Consumer2<ServerProvider, AuthProvider>(
                  builder: (context, serverProv, authProv, _) {
                    final detail = serverProv.currentServerDetail;
                    final currentUserId = authProv.currentUser?.id;
                    final isAdmin = detail?.yourRole == 'admin';
                    final isCreator = detail?.server.createdBy == currentUserId;
                    final groupName = detail?.server.name ?? widget.serverName;

                    return Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8, bottom: 8),
                      child: PopupMenuButton<String>(
                        color: isDark
                            ? DhanWiserColors.surfaceElevatedDark
                            : Colors.white,
                        icon: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.more_horiz_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onSelected: (value) {
                          if (value == 'reminder-settings') {
                            _showReminderSettingsSheet();
                          } else if (value == 'delete-group') {
                            _confirmDeleteOrLeave(
                              canDelete: true,
                              groupName: groupName,
                            );
                          } else if (value == 'leave-group') {
                            _confirmDeleteOrLeave(
                              canDelete: false,
                              groupName: groupName,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          if (isAdmin)
                            PopupMenuItem(
                              value: 'reminder-settings',
                              child: Text(
                                'Reminder Settings',
                                style: GoogleFonts.inter(fontSize: 14),
                              ),
                            ),
                          if (isCreator)
                            PopupMenuItem(
                              value: 'delete-group',
                              child: Text(
                                'Delete Group',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: DhanWiserColors.coral,
                                ),
                              ),
                            ),
                          if (!isCreator)
                            PopupMenuItem(
                              value: 'leave-group',
                              child: Text(
                                'Leave Group',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: DhanWiserColors.coral,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: grad,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Consumer<ServerProvider>(
                      builder: (context, serverProv, _) {
                        final detail = serverProv.currentServerDetail;
                        final name = detail?.server.name ?? widget.serverName;
                        final memberCount = detail?.members.length ?? 0;

                        return Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 56, right: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Server icon
                              Hero(
                                tag: 'server_avatar_${widget.serverId}',
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                name,
                                style: GoogleFonts.inter(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$memberCount members',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: cs.primary,
                    unselectedLabelColor: sub,
                    indicatorColor: cs.primary,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                    unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Expenses'),
                      Tab(text: 'Balances'),
                      Tab(text: 'Members'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildExpensesTab(isDark, surface, text, sub),
            _buildBalancesTab(isDark, surface, text, sub),
            _buildMembersTab(isDark, surface, text, sub),
          ],
        ),
      ),
    );
  }

  // ── EXPENSES TAB ──
  Widget _buildExpensesTab(bool isDark, Color surface, Color text, Color sub) {
    final cs = Theme.of(context).colorScheme;
    if (_loadingExpenses && _expensePage == 1) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => ShimmerLoading(
          child: Container(height: 72, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
        ),
      );
    }

    if (_expenses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No expenses yet',
        subtitle: 'Tap + to add the first one',
      );
    }

    final categoryIcons = [Icons.restaurant_rounded, Icons.directions_car_rounded, Icons.home_rounded, Icons.movie_rounded, Icons.shopping_cart_rounded, Icons.lightbulb_rounded, Icons.sports_esports_rounded, Icons.coffee_rounded];

    return ListView.builder(
      controller: _expenseScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _expenses.length + (_hasMoreExpenses || _loadingMoreExpenses ? 1 : 0),
      itemBuilder: (context, index) {
        // "Load more" indicator at the bottom
        if (index >= _expenses.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: cs.primary,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          );
        }
        final e = _expenses[index];
        final catIcon = categoryIcons[e.title.hashCode.abs() % categoryIcons.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SwipeableExpenseRow(
            title: e.title,
            onEdit: () {
              Navigator.pushNamed(context, '/add-expense', arguments: {
                'serverId': widget.serverId,
              }).then((_) => _loadData());
            },
            onDelete: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ExpenseService.deleteExpense(e.id);
                await _loadData();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Deleted "${e.title}"'),
                      backgroundColor: DhanWiserColors.positive,
                    ),
                  );
                }
              } catch (err) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: $err'),
                      backgroundColor: DhanWiserColors.negative,
                    ),
                  );
                }
              }
            },
            child: BouncingButton(
              onTap: () {
                Navigator.pushNamed(context, '/expense-detail', arguments: {
                  'title': e.title,
                  'amount': '₹${e.totalAmount.toStringAsFixed(2)}',
                  'date': '${e.expenseDate.day}/${e.expenseDate.month}/${e.expenseDate.year}',
                  'paidBy': e.createdByUsername,
                  'participants': e.participants.map((p) {
                    return {
                      'name': p.fullName ?? p.username,
                      'amountPaid': p.amountPaid,
                      'amountOwed': p.amountOwed,
                    };
                  }).toList(),
                });
              },
              child: Container(
                padding: const EdgeInsets.all(14),
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
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(catIcon, color: cs.primary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Paid by ${e.createdByUsername}',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: sub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${e.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fade(duration: 200.ms, delay: ((index % 10) * 30).ms)
         .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic, duration: 200.ms);
      },
    );
  }

  // ── BALANCES TAB ──
  Widget _buildBalancesTab(bool isDark, Color surface, Color text, Color sub) {
    final cs = Theme.of(context).colorScheme;
    if (_loadingBalances) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final serverProv = Provider.of<ServerProvider>(context, listen: false);
    final currentUserId = authProv.currentUser?.id;
    final members = serverProv.currentServerDetail?.members ?? [];
    final isAdmin = members.any(
      (m) => m.userId == currentUserId && m.role == 'admin',
    );

    if (_balances.isEmpty) {
      return _buildEmptyState(
        icon: Icons.account_balance_outlined,
        title: 'All settled up!',
        subtitle: 'No outstanding balances',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── How Balances Work — Explainer ──
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: isDark ? 0.2 : 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                leading: Icon(Icons.info_outline_rounded, color: cs.primary, size: 20),
                title: Text(
                  'How balances work',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
                children: [
                  _buildExplainerRow(
                    Icons.person_rounded,
                    'Payer',
                    'The person who paid for an expense upfront.',
                    DhanWiserColors.teal,
                    cs,
                  ),
                  const SizedBox(height: 8),
                  _buildExplainerRow(
                    Icons.people_rounded,
                    'Debtors',
                    'Everyone who shares the expense owes their portion to the payer.',
                    DhanWiserColors.coral,
                    cs,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calculation',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Balance = Total Paid − Total Owed',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant, height: 1.5),
                            children: [
                              TextSpan(
                                text: '▲ Positive',
                                style: TextStyle(color: DhanWiserColors.teal, fontWeight: FontWeight.w600),
                              ),
                              const TextSpan(text: ' → Others owe you (you get back)\n'),
                              TextSpan(
                                text: '▼ Negative',
                                style: TextStyle(color: DhanWiserColors.coral, fontWeight: FontWeight.w600),
                              ),
                              const TextSpan(text: ' → You owe others (you need to pay)'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Balance cards
          ..._balances.map((b) {
            final isPositive = b.balance >= 0;
            final color = isPositive ? DhanWiserColors.teal : DhanWiserColors.coral;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
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
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        b.fullName.isNotEmpty ? b.fullName[0].toUpperCase() : '?',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: color,
                          fontSize: 18,
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
                          b.fullName,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: text,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '@${b.username}',
                          style: GoogleFonts.inter(fontSize: 12, color: sub),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${b.balance.abs().toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      Text(
                        isPositive ? 'gets back' : 'owes',
                        style: GoogleFonts.inter(fontSize: 11, color: color.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // Admin Reminders Action
          if (isAdmin && _balances.any((b) => b.balance < 0)) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final serverProv = Provider.of<ServerProvider>(context, listen: false);
                  final success = await serverProv.sendReminders(widget.serverId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Reminders sent!' : 'Failed to send reminders'),
                        backgroundColor: success ? DhanWiserColors.mint : DhanWiserColors.coral,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.notifications_active_rounded, size: 18),
                label: Text(
                  'Send Reminders',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DhanWiserColors.primary,
                  side: BorderSide(color: DhanWiserColors.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],

          // Suggestions
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'SETTLE UP',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sub,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            ..._suggestions.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: DhanWiserColors.primary.withValues(alpha: isDark ? 0.1 : 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          s.fromUsername,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: text, fontSize: 14),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward_rounded, size: 16, color: DhanWiserColors.primary),
                        ),
                        Text(
                          s.toUsername,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: text, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${s.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: DhanWiserColors.primary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showSettleUpDialog(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: DhanWiserColors.mint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Settle',
                        style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            )),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── MEMBERS TAB ──
  Widget _buildMembersTab(bool isDark, Color surface, Color text, Color sub) {
    final cs = Theme.of(context).colorScheme;
    return Consumer2<ServerProvider, AuthProvider>(
      builder: (context, serverProv, authProv, _) {
        if (serverProv.isLoading) {
          return Center(child: CircularProgressIndicator(color: cs.primary));
        }

        final members = serverProv.currentServerDetail?.members ?? [];
        final currentUserId = authProv.currentUser?.id;
        final isAdmin = members.any(
          (m) => m.userId == currentUserId && m.role == 'admin',
        );

        if (members.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline_rounded,
            title: 'No members',
            subtitle: 'Invite friends to this group',
          );
        }

        final memberColors = [
          DhanWiserColors.primary,
          DhanWiserColors.teal,
          DhanWiserColors.coral,
          DhanWiserColors.warning,
          const Color(0xFF74B9FF),
        ];

        return Column(
          children: [
            // ── Invite button (admin only) ──
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.pushNamed(
                        context,
                        '/friend-discovery',
                        arguments: {'serverId': widget.serverId, 'serverName': widget.serverName},
                      );
                      await _loadData();
                    },
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: Text(
                      'Invite Members',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DhanWiserColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final m = members[index];
                  final color = memberColors[index % memberColors.length];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
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
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Center(
                            child: Text(
                              m.fullName.isNotEmpty ? m.fullName[0].toUpperCase() : '?',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: color,
                                fontSize: 18,
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
                                m.fullName,
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: text, fontSize: 15),
                              ),
                              Text(
                                '@${m.username}',
                                style: GoogleFonts.inter(fontSize: 12, color: sub),
                              ),
                            ],
                          ),
                        ),
                        if (m.role == 'admin')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: DhanWiserColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Admin',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: DhanWiserColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final cs = Theme.of(context).colorScheme;
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
            child: Icon(icon, size: 30, color: cs.primary),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: cs.onSurface)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildExplainerRow(
    IconData icon,
    String label,
    String description,
    Color color,
    ColorScheme cs,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
