import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../theme/design_tokens.dart';

/// A luxury interactive spending trend area chart inspired by Revolut & Copilot Money.
class SpendingTrendChart extends StatefulWidget {
  final List<FlSpot>? spots;
  final List<String>? xLabels;
  final double totalAmount;
  final String periodLabel;
  final double? percentageChange;
  final ValueChanged<int>? onPeriodChanged;
  final int selectedPeriodIndex;

  const SpendingTrendChart({
    super.key,
    this.spots,
    this.xLabels,
    required this.totalAmount,
    this.periodLabel = 'This Week',
    this.percentageChange,
    this.onPeriodChanged,
    this.selectedPeriodIndex = 0,
  });

  @override
  State<SpendingTrendChart> createState() => _SpendingTrendChartState();
}

class _SpendingTrendChartState extends State<SpendingTrendChart> {
  int? _touchedSpotIndex;

  // Keep the empty fallback neutral; charts must never imply sample financial data.
  List<FlSpot> get _chartSpots =>
      widget.spots ??
      const [
        FlSpot(0, 0),
        FlSpot(1, 0),
        FlSpot(2, 0),
        FlSpot(3, 0),
        FlSpot(4, 0),
        FlSpot(5, 0),
        FlSpot(6, 0),
      ];

  List<String> get _dayLabels =>
      widget.xLabels ?? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final colors = DhanWiserColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryAccent = colors.primaryFixed;
    final spots = _chartSpots;

    // Calculate max Y for comfortable breathing room
    double maxY = 100;
    for (final s in spots) {
      if (s.y > maxY) maxY = s.y;
    }
    maxY = (maxY * 1.25).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: DhanWiserTokens.radiusMedium,
        border: Border.all(color: colors.outlineVariant),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0x060F172A),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Timeframe Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SPENDING OVERVIEW',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${widget.totalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: colors.textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (widget.percentageChange != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: (widget.percentageChange! >= 0
                                    ? colors.error
                                    : colors.tertiary)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.percentageChange! >= 0
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 12,
                                color: widget.percentageChange! >= 0
                                    ? colors.error
                                    : colors.tertiary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${widget.percentageChange! >= 0 ? '+' : ''}${widget.percentageChange!.toStringAsFixed(1)}%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: widget.percentageChange! >= 0
                                      ? colors.error
                                      : colors.tertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Filter Pills
              _buildPeriodSelector(context, colors),
            ],
          ),

          const SizedBox(height: 24),

          // Chart Area
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => colors.surfaceContainerHighest,
                    tooltipPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    tooltipMargin: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final dayName = spot.x.toInt() < _dayLabels.length
                            ? _dayLabels[spot.x.toInt()]
                            : '';
                        return LineTooltipItem(
                          '$dayName\n₹${spot.y.toStringAsFixed(0)}',
                          GoogleFonts.plusJakartaSans(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  touchCallback: (event, response) {
                    if (response?.lineBarSpots != null &&
                        response!.lineBarSpots!.isNotEmpty) {
                      setState(() {
                        _touchedSpotIndex =
                            response.lineBarSpots!.first.spotIndex;
                      });
                    } else {
                      setState(() {
                        _touchedSpotIndex = null;
                      });
                    }
                  },
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 3 > 0 ? maxY / 3 : 100,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                    strokeWidth: 0.8,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < _dayLabels.length) {
                          final isSelected = _touchedSpotIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _dayLabels[idx],
                              style: GoogleFonts.plusJakartaSans(
                                color: isSelected
                                    ? primaryAccent
                                    : colors.textDisabled,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    preventCurveOverShooting: true,
                    color: primaryAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final isTouched = index == _touchedSpotIndex;
                        return FlDotCirclePainter(
                          radius: isTouched ? 6 : 2.5,
                          color: isTouched ? primaryAccent : colors.surface,
                          strokeWidth: isTouched ? 3 : 2,
                          strokeColor: primaryAccent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryAccent.withValues(alpha: isDark ? 0.12 : 0.08),
                          primaryAccent.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, DhanWiserColors colors) {
    const periods = ['7D', '30D', '90D'];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.asMap().entries.map((entry) {
          final idx = entry.key;
          final title = entry.value;
          final isSelected = idx == widget.selectedPeriodIndex;

          return GestureDetector(
            onTap: () => widget.onPeriodChanged?.call(idx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? colors.surfaceContainerHighest
                        : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:
                      isSelected ? colors.textPrimary : colors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Category spending distribution donut chart with interactive selection.
class CategoryDonutChart extends StatefulWidget {
  final Map<String, double> categoryAmounts;
  final double totalAmount;

  const CategoryDonutChart({
    super.key,
    required this.categoryAmounts,
    required this.totalAmount,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touchedIndex = -1;

  Color _getCategoryColor(String category, DhanWiserColors colors) {
    final lower = category.toLowerCase();
    if (lower.contains('food') || lower.contains('dinner') || lower.contains('restaurant')) {
      return colors.catFood;
    }
    if (lower.contains('travel') || lower.contains('flight') || lower.contains('uber') || lower.contains('transport')) {
      return colors.catTransport;
    }
    if (lower.contains('rent') || lower.contains('housing') || lower.contains('flat')) {
      return colors.catRent;
    }
    if (lower.contains('groc')) {
      return colors.catGroceries;
    }
    if (lower.contains('util') || lower.contains('bill') || lower.contains('wifi')) {
      return colors.catUtilities;
    }
    return colors.catFun;
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('food') || lower.contains('dinner') || lower.contains('restaurant')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('travel') || lower.contains('flight') || lower.contains('transport')) {
      return Icons.directions_car_rounded;
    }
    if (lower.contains('rent') || lower.contains('flat')) {
      return Icons.home_rounded;
    }
    if (lower.contains('groc')) {
      return Icons.shopping_basket_rounded;
    }
    if (lower.contains('util') || lower.contains('bill')) {
      return Icons.bolt_rounded;
    }
    return Icons.local_activity_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colors = DhanWiserColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = widget.categoryAmounts;

    final total = widget.totalAmount > 0
        ? widget.totalAmount
        : categories.values.fold(0.0, (sum, val) => sum + val);

    final entries = categories.entries.toList();

    if (entries.isEmpty || total <= 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: DhanWiserTokens.radiusMedium,
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Text(
          'Category insights will appear after expenses are recorded.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: colors.textSecondary,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: DhanWiserTokens.radiusMedium,
        border: Border.all(color: colors.outlineVariant),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0x060F172A),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CATEGORY BREAKDOWN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                '${categories.length} categories',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textDisabled,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Donut + Center Content
          Row(
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 4,
                        centerSpaceRadius: 44,
                        sections: entries.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final e = entry.value;
                          final isTouched = idx == _touchedIndex;
                          final radius = isTouched ? 22.0 : 16.0;
                          final catColor = _getCategoryColor(e.key, colors);

                          return PieChartSectionData(
                            color: catColor,
                            value: e.value,
                            title: '',
                            radius: radius,
                          );
                        }).toList(),
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colors.textDisabled,
                          ),
                        ),
                        Text(
                          '₹${(total / 1000).toStringAsFixed(1)}k',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Categories Legend
              Expanded(
                child: Column(
                  children: entries.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final e = entry.value;
                    final pct = total > 0 ? (e.value / total * 100) : 0.0;
                    final catColor = _getCategoryColor(e.key, colors);
                    final isSelected = idx == _touchedIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _touchedIndex = isSelected ? -1 : idx;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? catColor.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                _getCategoryIcon(e.key),
                                size: 13,
                                color: catColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.key,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: colors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${pct.toStringAsFixed(0)}%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: catColor,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A sleek split ratio bar showing "Owed to you" vs "You owe" with animated percentages.
class BalanceRatioBar extends StatelessWidget {
  final double owedToYou;
  final double youOwe;

  const BalanceRatioBar({
    super.key,
    required this.owedToYou,
    required this.youOwe,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DhanWiserColors.of(context);
    final total = owedToYou + youOwe;

    final owedPct = total > 0 ? (owedToYou / total) : 0.5;
    final owePct = total > 0 ? (youOwe / total) : 0.5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colors.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Get ${(owedPct * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.tertiary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Give ${(owePct * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.error,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: (owedPct * 100).round().clamp(1, 99),
                    child: Container(color: colors.tertiary),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: (owePct * 100).round().clamp(1, 99),
                    child: Container(color: colors.error),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
