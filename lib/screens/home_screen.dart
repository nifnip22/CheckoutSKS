import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../logic/krs_logic.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';
import '../widgets/course_card.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // SATU-SATUNYA pemilik state keranjang
  final List<Course> _selectedCourses = [];

  // State lokal untuk search dan filter katalog
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: Semua, 1: Wajib, 2: Pilihan

  @override
  void initState() {
    super.initState();
    _initMandatoryCourses();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  /// Mata kuliah wajib otomatis terpilih, terkunci, dan selalu dihitung
  void _initMandatoryCourses() {
    for (final course in mockCourses) {
      if (KrsLogic.isMandatory(course)) {
        if (!_selectedCourses.any((c) => c.id == course.id)) {
          _selectedCourses.add(course);
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addCourse(Course course) {
    if (course.sisaKuota <= 0) return;
    if (_selectedCourses.any((c) => c.id == course.id)) return;

    if (!KrsLogic.canAddCourse(
      currentSelected: _selectedCourses,
      candidate: course,
      maxCreditLimit: maxSks,
    )) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Total SKS tidak boleh melebihi 24 SKS',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.primaryMaroon,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _selectedCourses.add(course);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${course.namaMk} berhasil ditambahkan',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeCourse(Course course) {
    if (KrsLogic.isMandatory(course)) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mata kuliah wajib tidak dapat dibatalkan'),
          backgroundColor: AppTheme.primaryMaroon,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _selectedCourses.removeWhere((c) => c.id == course.id);
    });
  }

  void _clearCart() {
    setState(() {
      _selectedCourses.clear();
      _initMandatoryCourses(); // Matkul wajib selalu diikutsertakan
    });
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          selectedCourses: _selectedCourses,
          onRemove: (course) {
            _removeCourse(course);
          },
          onSubmitted: _clearCart,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // Saring mata kuliah berdasarkan kata kunci dan chip filter
    final filteredCourses = mockCourses.where((c) {
      if (_selectedFilterIndex == 1 && c.tipe != CourseType.wajib) {
        return false;
      }
      if (_selectedFilterIndex == 2 && c.tipe != CourseType.pilihan) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final matchName = c.namaMk.toLowerCase().contains(_searchQuery);
        final matchKode = c.kode.toLowerCase().contains(_searchQuery);
        return matchName || matchKode;
      }
      return true;
    }).toList();

    final cartCount = _selectedCourses.length;
    final currentSks = KrsLogic.calculateTotalSks(_selectedCourses);
    final remainingQuota = KrsLogic.calculateRemainingQuota(
      _selectedCourses,
      maxCreditLimit: maxSks,
    );

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        titleSpacing: 16,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: 'Checkout',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              TextSpan(
                text: 'SKS',
                style: TextStyle(color: AppTheme.primaryMaroon),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              tooltip: 'Draf KRS',
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text(
                  '$cartCount',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppTheme.primaryMaroon,
                textColor: AppTheme.surfaceWhite,
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 26,
                  color: AppTheme.textPrimary,
                ),
              ),
              onPressed: _openCart,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // SKS Status Banner (Sesuai Aturan Tahap 2: Menampilkan Total SKS terhadap batas & sisa kuota)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      size: 20,
                      color: AppTheme.primaryMaroon,
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                        children: [
                          const TextSpan(text: 'Total SKS: '),
                          TextSpan(
                            text: '$currentSks/$maxSks',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryMaroon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.tintMaroon,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Sisa Kuota: $remainingQuota SKS',
                    style: const TextStyle(
                      color: AppTheme.primaryMaroon,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search & Filter Chips Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(
              children: [
                // Search Field
                Container(
                  height: 46,
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Chip Filter (Semua / Wajib / Pilihan)
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip(0, 'Semua'),
                      const SizedBox(width: 8),
                      _buildFilterChip(1, 'Wajib'),
                      const SizedBox(width: 8),
                      _buildFilterChip(2, 'Pilihan'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Catalog Grid
          Expanded(
            child: filteredCourses.isEmpty
                ? _buildEmptyCatalog()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 280,
                          mainAxisExtent: 236,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      final isSelected = _selectedCourses.any(
                        (c) => c.id == course.id,
                      );
                      final isLocked = KrsLogic.isMandatory(course);
                      final exceedsQuota =
                          !isSelected && course.sks > remainingQuota;

                      return CourseCard(
                        course: course,
                        isSelected: isSelected,
                        isLocked: isLocked,
                        exceedsQuota: exceedsQuota,
                        onTake: () => _addCourse(course),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryMaroon : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppTheme.primaryMaroon : AppTheme.borderColor,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.surfaceWhite : AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCatalog() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.tintMaroon,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: AppTheme.primaryMaroon,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mata kuliah tidak ditemukan',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba gunakan kata kunci atau filter lain',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
