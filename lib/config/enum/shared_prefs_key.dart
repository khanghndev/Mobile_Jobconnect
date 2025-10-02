enum SharedPrefsKey {
  isLoggedIn,
  token,
  lang,
  user
}

extension SharedPrefsKeyExtension on SharedPrefsKey {
  // Get shared prefs key value
  String get getVal {
    switch (this) {
      case SharedPrefsKey.token:
        return "token";
      case SharedPrefsKey.isLoggedIn:
        return 'is_logged_in';
      case SharedPrefsKey.user:
        return 'user';
      case SharedPrefsKey.lang:
        return 'lang';
    }
  }
}
