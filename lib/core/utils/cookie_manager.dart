class CookieManager {
  final Map<String, String> _cookies = {};

  void set(String key, String value) {
    _cookies[key] = value;
  }

  String? get(String key) {
    return _cookies[key];
  }

  void remove(String key) {
    _cookies.remove(key);
  }

  void clear() {
    _cookies.clear();
  }
} 