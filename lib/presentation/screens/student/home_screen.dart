import 'dart:async';
import 'package:flutter/material.dart';
import 'mess_detail_screen.dart';
import 'package:messgo/core/widgets/shimmer_widget.dart';
import 'package:messgo/core/services/bookmark_service.dart';
import 'package:messgo/core/widgets/filter_bottom_sheet.dart';
import 'package:messgo/core/widgets/today_menu_widget.dart';
import 'package:messgo/presentation/screens/profile/profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  Timer? _debounce;
  Set<String> _bookmarkedIds = {};
  String _searchQuery = '';
  String _selectedCategory = 'All';
  
  Map<String, dynamic> _filters = {
    'maxPrice': 5000.0,
    'minRating': 0.0,
    'vegOnly': false,
    'openNow': false,
  };

  final List<Map<String, dynamic>> messes = [
    {
      'id': '1',
      'name': 'Sharma Ji Ki Rasoi',
      'rating': 4.8,
      'reviews': 128,
      'price': 2500,
      'type': 'Pure Veg',
      'distance': '0.5 km',
      'address': 'Block A, Near College Gate',
      'features': ['AC', 'WiFi', 'Parking'],
      'timing': '7:00 AM - 10:00 PM',
      'menu': {
        'lunch': 'Dal Makhani, Rice, Roti, Salad, Papad',
        'dinner': 'Shahi Paneer, Rice, Roti, Dal, Sweet',
      },
    },
    {
      'id': '2',
      'name': 'Bhaijaan Dhaba',
      'rating': 4.5,
      'reviews': 89,
      'price': 2200,
      'type': 'Non-Veg',
      'distance': '0.8 km',
      'address': 'Main Road, Opposite Hostel',
      'features': ['Non-AC', 'Home Delivery'],
      'timing': '8:00 AM - 11:00 PM',
      'menu': {
        'lunch': 'Chicken Curry, Rice, Roti, Salad',
        'dinner': 'Mutton Biryani, Raita, Salad',
      },
    },
    {
      'id': '3',
      'name': 'Apna Kitchen',
      'rating': 4.7,
      'reviews': 256,
      'price': 2800,
      'type': 'Both',
      'distance': '1.2 km',
      'address': 'Sector 4, PG Complex',
      'features': ['AC', 'WiFi', 'GYM', 'Parking'],
      'timing': '6:30 AM - 10:30 PM',
      'menu': {
        'lunch': 'Mix Veg, Dal Tadka, Rice, Roti, Salad',
        'dinner': 'Butter Chicken, Veg Pulao, Roti, Dal',
      },
    },
    {
      'id': '4',
      'name': 'Tiffin Box',
      'rating': 4.3,
      'reviews': 67,
      'price': 2000,
      'type': 'Pure Veg',
      'distance': '0.3 km',
      'address': 'Lane 3, Student Hub',
      'features': ['Budget', 'Quick Service'],
      'timing': '7:00 AM - 9:00 PM',
      'menu': {
        'lunch': 'Rajma Chawal, Roti, Salad',
        'dinner': 'Aloo Matar, Rice, Roti, Dal',
      },
    },
  ];

  List<Map<String, dynamic>> get _filteredMesses {
    return messes.where((mess) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = mess['name'].toString().toLowerCase().contains(query);
        final typeMatch = mess['type'].toString().toLowerCase().contains(query);
        if (!nameMatch && !typeMatch) return false;
      }
      
      // Category filter
      if (_selectedCategory != 'All') {
        if (_selectedCategory == 'Veg' && mess['type'] != 'Pure Veg') return false;
        if (_selectedCategory == 'Non-Veg' && mess['type'] == 'Pure Veg') return false;
        if (_selectedCategory == 'Premium' && mess['price'] < 2500) return false;
        if (_selectedCategory == 'Budget' && mess['price'] > 2500) return false;
      }
      
      // Advanced filters
      if (mess['price'] > _filters['maxPrice']) return false;
      if (mess['rating'] < _filters['minRating']) return false;
      if (_filters['vegOnly'] == true && mess['type'] != 'Pure Veg') return false;
      
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await BookmarkService.getBookmarks();
    if (mounted) setState(() => _bookmarkedIds = bookmarks.toSet());
  }

  Future<void> _toggleBookmark(String messId) async {
    await BookmarkService.toggleBookmark(messId);
    await _loadBookmarks();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FilterBottomSheet(
        currentFilters: _filters,
        onApply: (filters) => setState(() => _filters = filters),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayMesses = _selectedIndex == 1 
        ? messes.where((m) => _bookmarkedIds.contains(m['id'])).toList()
        : _filteredMesses;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF00D4FF).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFF00D4FF),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Near College Gate',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white.withOpacity(0.7),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF00D4FF).withOpacity(0.2),
                            ),
                          ),
                          child: Stack(
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00D4FF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      _selectedIndex == 1 ? 'Saved Messes' : 'Find Your Perfect',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    if (_selectedIndex != 1)
                      const Text(
                        'Mess Today',
                        style: TextStyle(
                          color: Color(0xFF00D4FF),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 20),
                    
                    // Search Bar with Filter
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00D4FF).withOpacity(0.1),
                        ),
                      ),
                      child: TextField(
                        onChanged: (v) {
                          _debounce?.cancel();
                          _debounce = Timer(const Duration(milliseconds: 250), () {
                            if (mounted) setState(() => _searchQuery = v);
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search by name, food, location...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF9E9E9E),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: _showFilters,
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D4FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.tune,
                                color: Color(0xFF00D4FF),
                                size: 20,
                              ),
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Categories (only show on home, not saved)
            if (_selectedIndex != 1)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildCategory('All', Icons.restaurant_menu, _selectedCategory == 'All'),
                      _buildCategory('Veg', Icons.eco, _selectedCategory == 'Veg'),
                      _buildCategory('Non-Veg', Icons.egg_alt, _selectedCategory == 'Non-Veg'),
                      _buildCategory('Premium', Icons.star, _selectedCategory == 'Premium'),
                      _buildCategory('Budget', Icons.wallet, _selectedCategory == 'Budget'),
                      _buildCategory('Nearby', Icons.near_me, _selectedCategory == 'Nearby'),
                    ],
                  ),
                ),
              ),
            
            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D4FF),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedIndex == 1 ? 'Your Bookmarks' : 'Nearby Messes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (_filters['maxPrice'] < 5000 || _filters['minRating'] > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D4FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Filtered',
                          style: TextStyle(
                            color: Color(0xFF00D4FF),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Mess Cards
            _isLoading
                ? SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildShimmerCard(),
                        childCount: 3,
                      ),
                    ),
                  )
                : displayMesses.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No messes found',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final mess = displayMesses[index];
                              return RepaintBoundary(child: _buildMessCard(mess));
                            },
                            childCount: displayMesses.length,
                          ),
                        ),
                      ),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
      
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF00D4FF).withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4FF).withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
         child: BottomNavigationBar(
         currentIndex: _selectedIndex,
        onTap: (i) {
    if (i == 3) {
         Navigator.push(
           context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }     else {
            setState(() => _selectedIndex = i);
    }
  },
           backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF00D4FF),
            unselectedItemColor: const Color(0xFF9E9E9E),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              _buildNavItem(Icons.home_rounded, 0),
              _buildNavItem(Icons.bookmark_rounded, 1),
              _buildNavItem(Icons.qr_code_scanner_rounded, 2),
              _buildNavItem(Icons.person_rounded, 3),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF2979FF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 5),
                  ),
                ],
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? Colors.black : const Color(0xFF9E9E9E),
        ),
      ),
      label: '',
    );
  }

  Widget _buildShimmerCard() {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 320,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildCategory(String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF2979FF)],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(
                        color: const Color(0xFF00D4FF).withOpacity(0.1),
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.black : const Color(0xFF9E9E9E),
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00D4FF) : const Color(0xFF9E9E9E),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessCard(Map<String, dynamic> mess) {
    final isBookmarked = _bookmarkedIds.contains(mess['id']);
    
    return GestureDetector(
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return MessDetailScreen(mess: mess);
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = const Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.easeInOutCubic;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E1E1E),
                        const Color(0xFF0A0A0A),
                      ],
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 60,
                          color: const Color(0xFF00D4FF).withOpacity(0.2),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF141414),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Type badge
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: mess['type'] == 'Pure Veg'
                                ? Colors.green.withOpacity(0.9)
                                : mess['type'] == 'Non-Veg'
                                    ? Colors.red.withOpacity(0.9)
                                    : const Color(0xFF7C4DFF).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            mess['type'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Bookmark button
                      Positioned(
                        top: 16,
                        right: 56,
                        child: GestureDetector(
                          onTap: () => _toggleBookmark(mess['id']),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isBookmarked
                                    ? const Color(0xFF00D4FF)
                                    : Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              size: 20,
                              color: isBookmarked ? const Color(0xFF00D4FF) : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Rating badge
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00D4FF).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Color(0xFF00D4FF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${mess['rating']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mess['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mess['distance'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.people_outline,
                          size: 16,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${mess['reviews']} reviews',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Today's Menu Widget
                    TodayMenuWidget(menu: mess['menu'] ?? {}),
                    const SizedBox(height: 12),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (mess['features'] as List<String>).map((feature) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF00D4FF).withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            feature,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '?${mess['price']}',
                              style: const TextStyle(
                                color: Color(0xFF00D4FF),
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'per month',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00D4FF), Color(0xFF2979FF)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D4FF).withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(16),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                child: Text(
                                  'View Details',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}