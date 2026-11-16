import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_colors.dart';
import '../auth/login_screen.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ==========================================
  // STATE
  // ==========================================

  int _selectedIndex = 0;

  String _userName = 'Explorer';
  String _selectedNews = 'All';

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchTimer;

  List<Map<String, dynamic>> _results = [];
  List<Map<String, dynamic>> _bookmarks = [];

  bool _isLoading = true;
  String? _resultsError;

  static const String _baseUrl =
      'https://api.spaceflightnewsapi.net/v4/articles';

  static const String _bookmarkKey = 'bookmarked_articles';

  final List<String> _newsSources = [
    'All',
    'NASA',
    'SpacePolicyOnline.com',
    'Space Scout',
    'Spaceflight Now',
    'Arstechnica',
    'European Spaceflight',
  ];

  // ==========================================
  // INITIALIZATION
  // ==========================================

  @override
  void initState() {
    super.initState();
    _initializeHome();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeHome() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _userName = prefs.getString('user_name') ?? 'Explorer';
    });

    await _loadBookmarks();
    await _loadResults();
  }

  // ==========================================
  // API: LOAD ARTICLES
  // ==========================================

  Future<void> _loadResults() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _resultsError = null;
    });

    try {
      final queryParameters = <String, String>{
        'limit': '50',
        'ordering': '-published_at',
      };

      // Filter berdasarkan sumber berita
      if (_selectedNews != 'All') {
        queryParameters['news_site'] = _selectedNews;
      }

      // Pencarian judul dan ringkasan
      final keyword = _searchController.text.trim();

      if (keyword.isNotEmpty) {
        queryParameters['search'] = keyword;
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);

      debugPrint('================================');
      debugPrint('API URL: $uri');

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      debugPrint('API STATUS: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          throw Exception('Format respons API tidak valid.');
        }

        final List<dynamic> results = data['results'] ?? [];

        final articles = results.map((item) {
          return Map<String, dynamic>.from(item);
        }).toList();

        if (!mounted) return;

        setState(() {
          _results = articles;
          _isLoading = false;
        });

        debugPrint('JUMLAH BERITA: ${_results.length}');
        debugPrint('================================');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('ERROR API: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _resultsError = 'Gagal mengambil berita.\n$e';
      });
    }
  }

  // ==========================================
  // SEARCH
  // ==========================================

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _loadResults();
    });
  }

  // ==========================================
  // BOOKMARK: SHARED PREFERENCES
  // ==========================================

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();

    // Membaca bookmark baru.
    List<String> saved = prefs.getStringList(_bookmarkKey) ?? [];

    // Migrasi bookmark dari versi lama.
    if (saved.isEmpty) {
      saved =
          prefs.getStringList('favorite_results') ??
          prefs.getStringList('favorite_Results') ??
          [];
    }

    final loaded = <Map<String, dynamic>>[];

    for (final item in saved) {
      try {
        final decoded = jsonDecode(item);

        loaded.add(Map<String, dynamic>.from(decoded));
      } catch (e) {
        debugPrint('Bookmark tidak valid: $e');
      }
    }

    if (!mounted) return;

    setState(() {
      _bookmarks = loaded;
    });

    // Simpan menggunakan nama key baru.
    await prefs.setStringList(
      _bookmarkKey,
      loaded.map((item) => jsonEncode(item)).toList(),
    );
  }

  Future<void> _toggleBookmark(Map<String, dynamic> article) async {
    final id = article['id'];

    if (id == null) return;

    final exists = _isBookmarked(id);

    setState(() {
      if (exists) {
        _bookmarks.removeWhere(
          (item) => item['id'].toString() == id.toString(),
        );
      } else {
        _bookmarks.add(article);
      }
    });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _bookmarkKey,
      _bookmarks.map((item) => jsonEncode(item)).toList(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exists
              ? 'Berita dihapus dari bookmark.'
              : 'Berita berhasil ditambahkan ke bookmark!',
        ),
        backgroundColor: AppColors.purpleDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _isBookmarked(dynamic id) {
    return _bookmarks.any((item) => item['id'].toString() == id.toString());
  }

  // ==========================================
  // BOOKMARK SHEET
  // ==========================================

  void _showBookmarks() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.80,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.purpleSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bookmark_rounded,
                          color: AppColors.purple,
                          size: 25,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Bookmark Saya',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        Text(
                          '${_bookmarks.length} berita',
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  Expanded(
                    child: _bookmarks.isEmpty
                        ? _buildEmptyState(
                            Icons.bookmark_border_rounded,
                            'Belum ada bookmark',
                            'Simpan berita yang menarik untuk dibaca nanti.',
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(18),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 13,
                                  mainAxisSpacing: 13,
                                  childAspectRatio: 0.69,
                                ),
                            itemCount: _bookmarks.length,
                            itemBuilder: (context, index) {
                              return _buildArticleCard(
                                _bookmarks[index],
                                onBookmarkChanged: () {
                                  modalSetState(() {});
                                },
                              );
                            },
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

  // ==========================================
  // LOGOUT
  // ==========================================

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.setBool('is_logged_in', false);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // ==========================================
  // MAIN UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    // GradientBackground membungkus SELURUH Scaffold, sehingga AppBar
    // dan body memakai satu gradient yang sama (tidak ada garis pemisah).
    // Body tidak diperpanjang ke belakang AppBar, jadi konten tidak
    // saling tabrak dengan judul AppBar.
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // APP BAR (transparan, ikut gradient)
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          toolbarHeight: _selectedIndex == 0 ? 70 : kToolbarHeight,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedIndex == 0 ? 'SpaceNews Explorer' : 'Profil Saya',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                ),
              ),

              // SELAMAT DATANG (di bawah judul, hanya di tab Beranda)
              if (_selectedIndex == 0) ...[
                const SizedBox(height: 3),
                Text(
                  'Selamat datang, $_userName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),

          // BOOKMARK DI KANAN APPBAR
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: _showBookmarks,
                  tooltip: 'Bookmark',
                  icon: const Icon(
                    Icons.bookmark_outline_rounded,
                    color: AppColors.purple,
                    size: 28,
                  ),
                ),

                if (_bookmarks.isNotEmpty)
                  Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_bookmarks.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 8),
          ],
        ),

        body: SafeArea(
          top: false,
          child: IndexedStack(
            index: _selectedIndex,
            children: [_buildHomeTab(), _buildProfileTab()],
          ),
        ),

        // HANYA BERANDA DAN PROFIL
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.white.withValues(alpha: 0.85),
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.purpleSoft,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HOME TAB
  // ==========================================

  Widget _buildHomeTab() {
    return RefreshIndicator(
      color: AppColors.purple,
      onRefresh: _loadResults,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 15),
            sliver: SliverToBoxAdapter(child: _buildSearchField()),
          ),

          SliverToBoxAdapter(child: _buildNewsFilter()),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jelajahi Berita',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    '${_results.length} berita',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.purple),
              ),
            )
          else if (_resultsError != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildError(_resultsError!, _loadResults),
            )
          else if (_results.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(
                Icons.newspaper_rounded,
                'Berita tidak ditemukan',
                'Coba kata kunci atau sumber berita lainnya.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 13,
                  childAspectRatio: 0.69,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildArticleCard(_results[index]);
                }, childCount: _results.length),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // SEARCH FIELD
  // ==========================================

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Cari berita luar angkasa...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: () {
            _searchTimer?.cancel();
            _searchController.clear();
            _loadResults();
          },
          icon: const Icon(Icons.close_rounded),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  // ==========================================
  // NEWS FILTER
  // ==========================================

  Widget _buildNewsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Filter Sumber Berita',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.ink,
            ),
          ),
        ),

        const SizedBox(height: 11),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: _newsSources.map((source) {
              final selected = _selectedNews == source;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(source == 'All' ? 'Semua' : source),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) {
                    setState(() {
                      _selectedNews = source;
                    });

                    _loadResults();
                  },
                  selectedColor: AppColors.purple,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.secondaryText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  // ==========================================
  // ARTICLE CARD
  // ==========================================

  Widget _buildArticleCard(
    Map<String, dynamic> article, {
    VoidCallback? onBookmarkChanged,
  }) {
    final id = article['id'];
    final bool bookmarked = _isBookmarked(id);

    return GlassCard(
      padding: const EdgeInsets.all(8),
      radius: 24,
      blur: 12,
      opacity: 0.62,
      onTap: () => _showArticleDetail(article),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildArticleImage(article['image_url']),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () async {
                          await _toggleBookmark(article);
                          onBookmarkChanged?.call();
                        },
                        icon: Icon(
                          bookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: AppColors.purple,
                          size: 21,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['title'] ?? 'Tanpa judul',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 7),

                _buildNewsBadge(article['news_site'] ?? 'Unknown'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ARTICLE IMAGE
  // ==========================================

  Widget _buildArticleImage(dynamic imageUrl) {
    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return _buildImagePlaceholder();
    }

    return Image.network(
      imageUrl.toString(),
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.purple,
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildImagePlaceholder();
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.purpleSoft,
      child: const Center(
        child: Icon(
          Icons.rocket_launch_rounded,
          size: 55,
          color: AppColors.purple,
        ),
      ),
    );
  }

  // ==========================================
  // NEWS BADGE
  // ==========================================

  Widget _buildNewsBadge(String newsSite) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.purpleSoft.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        newsSite,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.purpleDark,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ==========================================
  // ARTICLE DETAIL
  // ==========================================

  void _showArticleDetail(Map<String, dynamic> article) {
    final authors = article['authors'] as List? ?? [];

    final authorNames = authors
        .map((author) => author['name'] ?? '')
        .where((name) => name.toString().isNotEmpty)
        .join(', ');

    final publishedAt = _formatDate(article['published_at']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.purpleSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: _buildArticleImage(article['image_url']),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      article['title'] ?? 'Tanpa judul',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildNewsBadge(article['news_site'] ?? 'Unknown'),

                    const SizedBox(height: 20),

                    _buildDetailRow('Sumber', article['news_site'] ?? '-'),

                    _buildDetailRow('Tanggal', publishedAt),

                    _buildDetailRow(
                      'Penulis',
                      authorNames.isEmpty ? '-' : authorNames,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Ringkasan Berita',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      article['summary'] ?? 'Tidak ada ringkasan.',
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _toggleBookmark(article);
                          modalSetState(() {});
                        },
                        icon: Icon(
                          _isBookmarked(article['id'])
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                        ),
                        label: Text(
                          _isBookmarked(article['id'])
                              ? 'Hapus dari Bookmark'
                              : 'Tambah ke Bookmark',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // FORMAT DATE
  // ==========================================

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    try {
      final date = DateTime.parse(value.toString()).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;

      return '$day/$month/$year';
    } catch (e) {
      return value.toString();
    }
  }

  // ==========================================
  // DETAIL ROW
  // ==========================================

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const Text(': '),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PROFILE TAB
  // ==========================================

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 5),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.pink, AppColors.purple],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: 0.3),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const CircleAvatar(
                radius: 54,
                backgroundColor: AppColors.purpleSoft,
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.purple,
                  size: 60,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            _userName,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'SpaceNews Explorer',
            style: TextStyle(color: AppColors.secondaryText),
          ),

          const SizedBox(height: 22),

          // BOOKMARK SUMMARY
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bookmark_rounded,
                  color: AppColors.purple,
                  size: 24,
                ),

                const SizedBox(width: 10),

                Text(
                  '${_bookmarks.length} berita tersimpan',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _profileMenu(
            Icons.bookmark_rounded,
            'Bookmark Saya',
            'Lihat berita yang telah disimpan',
            _showBookmarks,
          ),

          _profileMenu(
            Icons.logout_rounded,
            'Keluar',
            'Logout dari akun',
            _logout,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PROFILE MENU
  // ==========================================

  Widget _profileMenu(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    final Color accent = isLogout ? Colors.redAccent : AppColors.purple;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      radius: 22,
      blur: 10,
      opacity: 0.66,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isLogout ? Colors.redAccent : AppColors.ink,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 65, color: AppColors.purpleSoft),

            const SizedBox(height: 15),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ERROR STATE
  // ==========================================

  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.redAccent,
              size: 55,
            ),

            const SizedBox(height: 15),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondaryText),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
