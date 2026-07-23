import 'package:flutter/material.dart';
import '../models/course_receipt.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<PersonRecord> records;

  const StatisticsScreen({super.key, required this.stats, required this.records});

  @override
  Widget build(BuildContext context) {
    final totalAmount = (stats['totalAmount'] ?? 0) as num;
    final totalReceived = (stats['totalReceived'] ?? 0) as num;
    final totalRemaining = (stats['totalRemaining'] ?? 0) as num;
    final year1444Total = (stats['year1444Total'] ?? 0) as num;
    final year1445Total = (stats['year1445Total'] ?? 0) as num;
    final year1446Total = (stats['year1446Total'] ?? 0) as num;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('الإحصائيات والتقارير'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            Row(
              children: [
                Expanded(child: _buildStatCard('إجمالي السجلات', '${stats['totalRecords'] ?? 0}', Icons.people_rounded, AppTheme.primaryColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('السجلات المكتملة', '${stats['completedCount'] ?? 0}', Icons.check_circle_rounded, AppTheme.successColor)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('إجمالي المبالغ', '${totalAmount.toStringAsFixed(0)} ر', Icons.account_balance_wallet_rounded, AppTheme.accentColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('المبالغ المتبقية', '${totalRemaining.toStringAsFixed(0)} ر', Icons.pending_rounded, AppTheme.warningColor)),
              ],
            ),
            const SizedBox(height: 20),

            // Payment Progress
            _buildSectionTitle('نسبة الإنجاز'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildProgressCircle(
                          totalAmount > 0 ? totalReceived / totalAmount : 0,
                          '${totalAmount > 0 ? ((totalReceived / totalAmount) * 100).toStringAsFixed(0) : 0}%',
                          'نسبة الاستلام',
                          AppTheme.primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildAmountInfo('المُستلَم', totalReceived.toDouble(), AppTheme.successColor),
                        const Expanded(child: Divider()),
                        _buildAmountInfo('الإجمالي', totalAmount.toDouble(), AppTheme.primaryColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Year-wise breakdown
            _buildSectionTitle('توزيع السنوات الهجرية'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildYearRow('عام 1444', stats['year1444Count'] ?? 0, year1444Total.toDouble(), AppTheme.year1444Color, AppTheme.year1444Light),
                    const Divider(height: 24),
                    _buildYearRow('عام 1445', stats['year1445Count'] ?? 0, year1445Total.toDouble(), AppTheme.year1445Color, AppTheme.year1445Light),
                    const Divider(height: 24),
                    _buildYearRow('عام 1446', stats['year1446Count'] ?? 0, year1446Total.toDouble(), AppTheme.year1446Color, AppTheme.year1446Light),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Status breakdown
            _buildSectionTitle('توزيع الحالات'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatusTile(
                        'مسلم',
                        stats['muslimCount'] ?? 0,
                        Icons.check_circle_outline_rounded,
                        AppTheme.successColor,
                        AppTheme.successLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatusTile(
                        'غير مسلم',
                        stats['nonMuslimCount'] ?? 0,
                        Icons.cancel_outlined,
                        AppTheme.errorColor,
                        AppTheme.errorLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Top records
            if (records.isNotEmpty) ...[
              _buildSectionTitle('أعلى المبالغ'),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: (records..sort((a, b) => b.amount.compareTo(a.amount)))
                        .take(5)
                        .map((r) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    r.number.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(r.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                              ),
                              Text(
                                '${r.amount.toStringAsFixed(0)} ريال',
                                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: AppTheme.successColor),
                              ),
                            ],
                          ),
                        ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                  Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle(double progress, String centerText, String label, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: color.withAlpha(30),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(centerText, style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w700, color: color)),
                  Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInfo(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text('${value.toStringAsFixed(0)} ريال', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: color, fontSize: 16)),
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildYearRow(String label, int count, double total, Color color, Color bgColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
          child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: color, fontSize: 13)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.7,
              minHeight: 8,
              backgroundColor: bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$count سجل', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.textSecondary)),
            Text('${total.toStringAsFixed(0)} ر', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: color, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusTile(String label, int count, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count', style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700, color: color)),
              Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: color.withAlpha(179))),
            ],
          ),
        ],
      ),
    );
  }
}
