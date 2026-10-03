import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../logic/krs_logic.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final List<Course> selectedCourses;
  final ValueChanged<Course> onRemove;
  final VoidCallback onSubmitted;

  const CartScreen({
    super.key,
    required this.selectedCourses,
    required this.onRemove,
    required this.onSubmitted,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _searchController = TextEditingController();
  CourseType _activeTab = CourseType.wajib;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMk = widget.selectedCourses.length;
    final totalSks = KrsLogic.calculateTotalSks(widget.selectedCourses);

    final wajibCount = widget.selectedCourses
        .where((c) => c.tipe == CourseType.wajib)
        .length;
    final pilihanCount = widget.selectedCourses
        .where((c) => c.tipe == CourseType.pilihan)
        .length;

    // Filter courses for active tab and search query
    final displayedCourses = widget.selectedCourses.where((c) {
      if (c.tipe != _activeTab) return false;
      if (_searchQuery.isNotEmpty) {
        final matchName = c.namaMk.toLowerCase().contains(_searchQuery);
        final matchKode = c.kode.toLowerCase().contains(_searchQuery);
        return matchName || matchKode;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Draf KRS ($totalMk)',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari mata kuliah',
                      hintStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.textSecondary,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                size: 18,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Pill Toggle (Wajib / Pilihan)
                Container(
                  height: 44,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabPill(
                          title: 'Wajib ($wajibCount)',
                          isSelected: _activeTab == CourseType.wajib,
                          onTap: () {
                            setState(() {
                              _activeTab = CourseType.wajib;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildTabPill(
                          title: 'Pilihan ($pilihanCount)',
                          isSelected: _activeTab == CourseType.pilihan,
                          onTap: () {
                            setState(() {
                              _activeTab = CourseType.pilihan;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Course List or Empty State
          Expanded(
            child: displayedCourses.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: displayedCourses.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final course = displayedCourses[index];
                      return _buildCartItemCard(course);
                    },
                  ),
          ),

          // Floating Bottom Summary Bar
          _buildFloatingBottomBar(context, totalSks),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryMaroon : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.surfaceWhite : AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemCard(Course course) {
    final isMandatory = KrsLogic.isMandatory(course);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Code Tint Box with Maroon Course Code
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppTheme.tintMaroon,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                course.kode,
                style: const TextStyle(
                  color: AppTheme.primaryMaroon,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Course Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    course.namaMk,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    course.namaDosen,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${course.sks} SKS',
                    style: const TextStyle(
                      color: AppTheme.primaryMaroon,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),

            // Action: Lock Icon for mandatory or Delete for elective
            if (isMandatory)
              IconButton(
                icon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppTheme.primaryMaroon,
                  size: 20,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mata kuliah wajib tidak dapat dibatalkan'),
                      backgroundColor: AppTheme.primaryMaroon,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Mata kuliah wajib (terkunci)',
              )
            else
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFF9E9E9E),
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    widget.onRemove(course);
                  });
                },
                tooltip: 'Hapus dari draf',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isFiltering = _searchQuery.isNotEmpty;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.tintMaroon,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 40,
                  color: AppTheme.primaryMaroon,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isFiltering
                    ? 'Tidak ada mata kuliah yang cocok'
                    : 'Belum ada mata kuliah ${_activeTab.label.toLowerCase()} yang dipilih',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isFiltering
                    ? 'Coba ubah kata kunci pencarian Anda'
                    : 'Kembali ke katalog untuk memilih mata kuliah',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(BuildContext context, int totalSks) {
    final isCartEmpty = widget.selectedCourses.isEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.pillRadius),
          topRight: Radius.circular(AppTheme.pillRadius),
        ),
        boxShadow: AppTheme.floatingBarShadow,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total: $totalSks SKS',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'maks. $maxSks SKS',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
            FilledButton(
              onPressed: isCartEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            selectedCourses: widget.selectedCourses,
                            onSubmitted: widget.onSubmitted,
                          ),
                        ),
                      );
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryMaroon,
                foregroundColor: AppTheme.surfaceWhite,
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                disabledForegroundColor: const Color(0xFF9CA3AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    'Lanjut Pengajuan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
