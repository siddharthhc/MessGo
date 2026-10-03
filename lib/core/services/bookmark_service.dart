import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _key = 'bookmarked_messes';
  
  static Future<List<String>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];
    return List<String>.from(jsonDecode(data));
  }
  
  static Future<void> toggleBookmark(String messId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();
    
    if (bookmarks.contains(messId)) {
      bookmarks.remove(messId);
    } else {
      bookmarks.add(messId);
    }
    
    await prefs.setString(_key, jsonEncode(bookmarks));
  }
  
  static Future<bool> isBookmarked(String messId) async {
    final bookmarks = await getBookmarks();
    return bookmarks.contains(messId);
  }
}
