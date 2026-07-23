import 'package:flutter/material.dart';
import '../models/course_receipt.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import 'add_receipt_screen.dart';
import 'receipt_detail_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper();
  List<PersonRecord> _records = [];
  List<PersonRecord> _filteredRecords = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedYear = 'الكل';
  String _selectedSort = 'الرقم';
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  late AnimationController _fabController;
  late Animation<double> _fabRotation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabRotation = Tween<double>(begin: 0, end: 0.375).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
    _loadRecords();
    _searchController.addListener(_filterRecords);
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final records = await _db.getAllPersonRecords();
    final stats = await _db.getStatistics();
    if (mounted) {
      setState(() {
        _records = records;
        _stats = stats;
        _isLoading = false;
        _filterAndSort();
      });
    }
  }

  void _filterRecords() => _filterAndSort();

  void _filterAndSort() {
    final query = _searchController.text.toLowerCase().trim();
    var filtered = _records.where((r) {
      final matchesSearch = query.isEmpty ||
          r.name.toLowerCase().contains(query) ||
          r.residence.toLowerCase().contains(query) ||
          r.number.toString().contains(query);
      final matchesYear = _selectedYear == 'الكل' ||
          (_selectedYear == '1444' && r.year1444 != null) ||
          (_selectedYear == '1445' && r.year1445 != null) ||
          (_selectedYear == '1446' && r.year1446 != null);
      return matchesSearch && matchesYear;
    }).toList();

    filtered.sort((a, b) {
      switch (_selectedSort) {
        case 'الاسم': return a.name.compareTo(b.name);
        case 'المبلغ': return b.amount.compareTo(a.amount);
        case 'الرقم': return a.number.compareTo(b.number);
        default: return a.number.compareTo(b.number);
      }
    });

    setState(() => _filteredRecords = filtered);
  }

  void _deleteRecord(PersonRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف السجل'),
        content: Text('هل تريد حذف سجل "${record.name}"؟\nلا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true && record.id != null) {
      await _db.deletePersonRecord(record.id!);
      await _loadRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف سجل "${record.name}" بنجاح'),
            backgroundColor: AppTheme.errorColor,
            action: SnackBarAction(
              label: 'حسناً',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else ...[
            SliverToBoxAdapter(child: _buildStatsRow()),
            SliverToBoxAdapter(child: _buildSearchAndFilter()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'السجلات (${_filteredRecords.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    if (_filteredRecords.isNotEmpty)
                      Text(
                        'المجموع: ${_filteredRecords.fold<double>(0, (s, r) => s + r.amount).toStringAsFixed(0)} ريال',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.successColor,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_filteredRecords.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildRecordCard(_filteredRecords[index], index),
                    childCount: _filteredRecords.length,
                  ),
                ),
              ),
          ],
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'كشف استلام المقررات',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'السنوي لحارس القاعة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 28),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => StatisticsScreen(stats: _stats, records: _records)),
                        ),
                        tooltip: 'الإحصائيات',
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

  Widget _buildStatsRow() {
    return Container(
      color: AppTheme.primaryColor,
      child: Container(
        margin: const EdgeInsets.only(top: 0),
        decoration: const BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(
          children: [
            _buildMiniStat(
              icon: Icons.people_rounded,
              label: 'إجمالي',
              value: '${_stats['totalRecords'] ?? 0}',
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            _buildMiniStat(
              icon: Icons.attach_money_rounded,
              label: 'المبالغ',
              value: '${((_stats['totalAmount'] ?? 0) as num).toStringAsFixed(0)}',
              color: AppTheme.successColor,
            ),
            const SizedBox(width: 12),
            _buildMiniStat(
              icon: Icons.check_circle_rounded,
              label: 'مكتمل',
              value: '${_stats['completedCount'] ?? 0}',
              color: AppTheme.accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو السكن أو الرقم...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _filterRecords();
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('السنة: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(width: 8),
                ...['الكل', '1444', '1445', '1446'].map((y) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(y, style: const TextStyle(fontSize: 13)),
                    selected: _selectedYear == y,
                    onSelected: (_) => setState(() {
                      _selectedYear = y;
                      _filterAndSort();
                    }),
                    selectedColor: AppTheme.primaryColor.withAlpha(204),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedYear == y ? Colors.white : AppTheme.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: _selectedYear == y ? AppTheme.primaryColor : AppTheme.dividerColor,
                      ),
                    ),
                  ),
                )),
                const SizedBox(width: 12),
                const Text('ترتيب: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(width: 8),
                ...['الرقم', 'الاسم', 'المبلغ'].map((s) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(s, style: const TextStyle(fontSize: 13)),
                    selected: _selectedSort == s,
                    onSelected: (_) => setState(() {
                      _selectedSort = s;
                      _filterAndSort();
                    }),
                    selectedColor: AppTheme.accentColor,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedSort == s ? Colors.white : AppTheme.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: _selectedSort == s ? AppTheme.accentColor : AppTheme.dividerColor,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(PersonRecord record, int index) {
    final hasYear1444 = record.year1444 != null;
    final hasYear1445 = record.year1445 != null;
    final hasYear1446 = record.year1446 != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReceiptDetailScreen(record: record)),
            );
            if (result == true) _loadRecords();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Number badge
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            record.number.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (record.residence.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textHint),
                                  const SizedBox(width: 3),
                                  Text(
                                    record.residence,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.monetization_on_outlined, size: 13, color: AppTheme.successColor),
                                const SizedBox(width: 3),
                                Text(
                                  '${record.amount.toStringAsFixed(0)} ريال',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.successColor,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Actions menu
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddReceiptScreen(record: record)),
                            );
                            if (result == true) _loadRecords();
                          } else if (value == 'delete') {
                            _deleteRecord(record);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded, color: AppTheme.primaryColor, size: 20),
                                SizedBox(width: 8),
                                Text('تعديل', style: TextStyle(fontFamily: 'Cairo')),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor, size: 20),
                                SizedBox(width: 8),
                                Text('حذف', style: TextStyle(color: AppTheme.errorColor, fontFamily: 'Cairo')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Year indicators
                if (hasYear1444 || hasYear1445 || hasYear1446)
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Row(
                      children: [
                        if (hasYear1444) _buildYearBadge('١٤٤٤', record.year1444!, AppTheme.year1444Color, AppTheme.year1444Light, record.year1444Status),
                        if (hasYear1444 && (hasYear1445 || hasYear1446)) const SizedBox(width: 8),
                        if (hasYear1445) _buildYearBadge('١٤٤٥', record.year1445!, AppTheme.year1445Color, AppTheme.year1445Light, record.year1445Status),
                        if (hasYear1445 && hasYear1446) const SizedBox(width: 8),
                        if (hasYear1446) _buildYearBadge('١٤٤٦', record.year1446!, AppTheme.year1446Color, AppTheme.year1446Light, record.year1446Status),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearBadge(String year, double amount, Color color, Color bgColor, String? status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            year,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${amount.toStringAsFixed(0)}ر',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(15),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد سجلات',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'لا توجد نتائج للبحث "${_searchController.text}"'
                  : 'ابدأ بإضافة سجل جديد بالضغط على +',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddReceiptScreen()),
        );
        if (result == true) _loadRecords();
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('إضافة سجل', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 6,
    );
  }
}
