enum SharedPrefsKey {
  token,
  lang,
  user,
  sessionId,
  idUserAppWrite,
  idUser,
  favoritePodcasts,
  roleName,
}

extension SharedPrefsKeyExtension on SharedPrefsKey {
  // Get shared prefs key value
  String get getVal {
    switch (this) {
      case SharedPrefsKey.token:
        return "token";
      case SharedPrefsKey.user:
        return 'user';
      case SharedPrefsKey.lang:
        return 'lang';
      case SharedPrefsKey.sessionId:
        return 'session_id';
      case SharedPrefsKey.idUserAppWrite:
        return 'id_user_appwrite';
      case SharedPrefsKey.idUser:
        return 'id_user';
      case SharedPrefsKey.favoritePodcasts:
        return 'favorite_podcasts';
      case SharedPrefsKey.roleName:
        return 'role_name';
    }
  }
}
