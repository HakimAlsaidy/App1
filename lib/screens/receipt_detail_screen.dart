import 'package:flutter/material.dart';
import '../models/course_receipt.dart';
import '../theme/app_theme.dart';
import 'add_receipt_screen.dart';

class ReceiptDetailScreen extends StatelessWidget {
  final PersonRecord record;
  const ReceiptDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildInfoSection(context),
                const SizedBox(height: 16),
                _buildPaymentProgress(),
                const SizedBox(height: 16),
                if (record.year1444 != null) _buildYearCard(context, '1444', record.year1444!, record.year1444Status, AppTheme.year1444Color, AppTheme.year1444Light),
                if (record.year1444 != null) const SizedBox(height: 12),
                if (record.year1445 != null) _buildYearCard(context, '1445', record.year1445!, record.year1445Status, AppTheme.year1445Color, AppTheme.year1445Light),
                if (record.year1445 != null) const SizedBox(height: 12),
                if (record.year1446 != null) _buildYearCard(context, '1446', record.year1446!, record.year1446Status, AppTheme.year1446Color, AppTheme.year1446Light),
                if (record.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildNotesCard(),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddReceiptScreen(record: record)),
            );
            if (result == true && context.mounted) Navigator.pop(context, true);
          },
          tooltip: 'تعديل',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryDark, AppTheme.primaryLight],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(26),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withAlpha(77), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            record.number.toString(),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.name,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (record.residence.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    record.residence,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المعلومات الأساسية',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.tag_rounded, 'الرقم', record.number.toString(), AppTheme.primaryColor),
            const Divider(height: 16),
            _buildInfoRow(Icons.person_rounded, 'الاسم', record.name, AppTheme.primaryColor),
            if (record.residence.isNotEmpty) ...[
              const Divider(height: 16),
              _buildInfoRow(Icons.location_on_rounded, 'السكن', record.residence, AppTheme.primaryColor),
            ],
            const Divider(height: 16),
            _buildInfoRow(
              Icons.monetization_on_rounded,
              'المبلغ الإجمالي',
              '${record.amount.toStringAsFixed(2)} ريال',
              AppTheme.successColor,
              valueStyle: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentProgress() {
    final total = record.amount;
    final received = record.totalReceivedAmount;
    final remaining = record.remainingAmount;
    final progress = total > 0 ? (received / total).clamp(0.0, 1.0) : 0.0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'حالة السداد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: record.isFullyPaid ? AppTheme.successLight : AppTheme.warningLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    record.paymentStatus,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: record.isFullyPaid ? AppTheme.successColor : AppTheme.warningColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: AppTheme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  record.isFullyPaid ? AppTheme.successColor : AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAmountBadge('المُستلَم', received, AppTheme.successColor, AppTheme.successLight),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAmountBadge('المتبقي', remaining, AppTheme.warningColor, AppTheme.warningLight),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAmountBadge('السنوات', record.activeYearsCount.toDouble(), AppTheme.infoColor, AppTheme.infoLight, isCount: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountBadge(String label, double value, Color color, Color bgColor, {bool isCount = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(
            isCount ? value.toInt().toString() : '${value.toStringAsFixed(0)} ر',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: isCount ? 22 : 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: color)),
        ],
      ),
    );
  }

  Widget _buildYearCard(BuildContext context, String year, double amount, String? status, Color color, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(77)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عام $year هجري',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: color, fontSize: 15),
                ),
                if (status != null && status != 'بدون')
                  Text(status, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: color.withAlpha(179))),
              ],
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} ريال',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notes_rounded, color: AppTheme.primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'الملاحظات',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              record.notes,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, height: 1.7, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor, {TextStyle? valueStyle}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppTheme.textHint)),
              Text(value, style: valueStyle ?? const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
