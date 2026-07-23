import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/course_receipt.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';

class AddReceiptScreen extends StatefulWidget {
  final PersonRecord? record;
  const AddReceiptScreen({super.key, this.record});

  @override
  State<AddReceiptScreen> createState() => _AddReceiptScreenState();
}

class _AddReceiptScreenState extends State<AddReceiptScreen>
    with TickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _numberCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _residenceCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _year1444Ctrl;
  late TextEditingController _year1445Ctrl;
  late TextEditingController _year1446Ctrl;
  late TextEditingController _notesCtrl;

  String _year1444Status = 'بدون';
  String _year1445Status = 'بدون';
  String _year1446Status = 'بدون';

  bool _hasYear1444 = false;
  bool _hasYear1445 = false;
  bool _hasYear1446 = false;

  late TabController _tabController;

  static const List<String> _statusOptions = ['بدون', 'مسلم', 'غير مسلم'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final r = widget.record;
    _numberCtrl = TextEditingController(text: r?.number.toString() ?? '');
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _residenceCtrl = TextEditingController(text: r?.residence ?? '');
    _amountCtrl = TextEditingController(text: r != null ? r.amount.toStringAsFixed(0) : '');
    _year1444Ctrl = TextEditingController(text: r?.year1444?.toStringAsFixed(0) ?? '');
    _year1445Ctrl = TextEditingController(text: r?.year1445?.toStringAsFixed(0) ?? '');
    _year1446Ctrl = TextEditingController(text: r?.year1446?.toStringAsFixed(0) ?? '');
    _notesCtrl = TextEditingController(text: r?.notes ?? '');

    if (r != null) {
      _year1444Status = r.year1444Status ?? 'بدون';
      _year1445Status = r.year1445Status ?? 'بدون';
      _year1446Status = r.year1446Status ?? 'بدون';
      _hasYear1444 = r.year1444 != null;
      _hasYear1445 = r.year1445 != null;
      _hasYear1446 = r.year1446 != null;
    }
  }

  @override
  void dispose() {
    _numberCtrl.dispose(); _nameCtrl.dispose(); _residenceCtrl.dispose();
    _amountCtrl.dispose(); _year1444Ctrl.dispose(); _year1445Ctrl.dispose();
    _year1446Ctrl.dispose(); _notesCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final record = PersonRecord(
        id: widget.record?.id,
        number: int.parse(_numberCtrl.text.trim()),
        name: _nameCtrl.text.trim(),
        residence: _residenceCtrl.text.trim(),
        amount: double.parse(_amountCtrl.text.trim().replaceAll(',', '')),
        year1444: (_hasYear1444 && _year1444Ctrl.text.isNotEmpty) ? double.parse(_year1444Ctrl.text) : null,
        year1444Status: (_hasYear1444 && _year1444Ctrl.text.isNotEmpty) ? _year1444Status : null,
        year1445: (_hasYear1445 && _year1445Ctrl.text.isNotEmpty) ? double.parse(_year1445Ctrl.text) : null,
        year1445Status: (_hasYear1445 && _year1445Ctrl.text.isNotEmpty) ? _year1445Status : null,
        year1446: (_hasYear1446 && _year1446Ctrl.text.isNotEmpty) ? double.parse(_year1446Ctrl.text) : null,
        year1446Status: (_hasYear1446 && _year1446Ctrl.text.isNotEmpty) ? _year1446Status : null,
        notes: _notesCtrl.text.trim(),
      );
      if (widget.record == null) {
        await _db.insertPersonRecord(record);
      } else {
        await _db.updatePersonRecord(record);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.record == null ? 'تم إضافة السجل بنجاح ✓' : 'تم تحديث السجل بنجاح ✓'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الحفظ: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.record != null;
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل السجل' : 'إضافة سجل جديد'),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppTheme.accentColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'المعلومات الأساسية', icon: Icon(Icons.person_rounded, size: 18)),
            Tab(text: 'السنوات الهجرية', icon: Icon(Icons.calendar_today_rounded, size: 18)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildYearsTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isEdit),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Number + Name Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: TextFormField(
                  controller: _numberCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'الرقم',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'مطلوب' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'الاسم مطلوب' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Residence
          TextFormField(
            controller: _residenceCtrl,
            decoration: const InputDecoration(
              labelText: 'السكن / المنطقة',
              prefixIcon: Icon(Icons.location_on_rounded),
              hintText: 'أدخل عنوان السكن (اختياري)',
            ),
          ),
          const SizedBox(height: 16),
          // Amount
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
            decoration: const InputDecoration(
              labelText: 'المبلغ الإجمالي',
              prefixIcon: Icon(Icons.monetization_on_rounded),
              suffixText: 'ريال',
              suffixStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: AppTheme.successColor),
            ),
            validator: (v) {
              if (v?.trim().isEmpty ?? true) return 'المبلغ مطلوب';
              if (double.tryParse(v!.replaceAll(',', '')) == null) return 'رقم غير صحيح';
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Notes
          TextFormField(
            controller: _notesCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'ملاحظات',
              prefixIcon: Icon(Icons.notes_rounded),
              alignLabelWithHint: true,
              hintText: 'أضف أي ملاحظات إضافية...',
            ),
          ),
          const SizedBox(height: 20),
          // Quick tip
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.infoLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.infoColor.withAlpha(77)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_rounded, color: AppTheme.infoColor, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'انتقل إلى تبويب "السنوات الهجرية" لإدخال بيانات كل عام',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppTheme.infoColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildYearSection(
            year: '1444',
            label: 'عام 1444 هجري',
            color: AppTheme.year1444Color,
            bgColor: AppTheme.year1444Light,
            isEnabled: _hasYear1444,
            controller: _year1444Ctrl,
            status: _year1444Status,
            onToggle: (v) => setState(() {
              _hasYear1444 = v;
              if (!v) { _year1444Ctrl.clear(); _year1444Status = 'بدون'; }
            }),
            onStatusChanged: (v) => setState(() => _year1444Status = v ?? 'بدون'),
          ),
          const SizedBox(height: 16),
          _buildYearSection(
            year: '1445',
            label: 'عام 1445 هجري',
            color: AppTheme.year1445Color,
            bgColor: AppTheme.year1445Light,
            isEnabled: _hasYear1445,
            controller: _year1445Ctrl,
            status: _year1445Status,
            onToggle: (v) => setState(() {
              _hasYear1445 = v;
              if (!v) { _year1445Ctrl.clear(); _year1445Status = 'بدون'; }
            }),
            onStatusChanged: (v) => setState(() => _year1445Status = v ?? 'بدون'),
          ),
          const SizedBox(height: 16),
          _buildYearSection(
            year: '1446',
            label: 'عام 1446 هجري',
            color: AppTheme.year1446Color,
            bgColor: AppTheme.year1446Light,
            isEnabled: _hasYear1446,
            controller: _year1446Ctrl,
            status: _year1446Status,
            onToggle: (v) => setState(() {
              _hasYear1446 = v;
              if (!v) { _year1446Ctrl.clear(); _year1446Status = 'بدون'; }
            }),
            onStatusChanged: (v) => setState(() => _year1446Status = v ?? 'بدون'),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSection({
    required String year,
    required String label,
    required Color color,
    required Color bgColor,
    required bool isEnabled,
    required TextEditingController controller,
    required String status,
    required ValueChanged<bool> onToggle,
    required ValueChanged<String?> onStatusChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isEnabled ? bgColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? color.withAlpha(128) : AppTheme.dividerColor,
          width: isEnabled ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header toggle
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isEnabled ? color : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: isEnabled ? Colors.white : Colors.grey,
                size: 22,
              ),
            ),
            title: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isEnabled ? color : AppTheme.textSecondary,
              ),
            ),
            trailing: Switch(
              value: isEnabled,
              onChanged: onToggle,
              activeColor: color,
            ),
          ),
          // Fields (shown only when enabled)
          if (isEnabled) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                      decoration: InputDecoration(
                        labelText: 'المبلغ',
                        suffixText: 'ريال',
                        suffixStyle: TextStyle(fontFamily: 'Cairo', color: color, fontWeight: FontWeight.w600),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: color, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: status,
                      decoration: InputDecoration(
                        labelText: 'الحالة',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: color, width: 2),
                        ),
                      ),
                      items: _statusOptions.map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                      )).toList(),
                      onChanged: onStatusChanged,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isEdit) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('إلغاء'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(isEdit ? Icons.save_rounded : Icons.add_circle_rounded),
              label: Text(isEdit ? 'حفظ التعديلات' : 'إضافة السجل'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
