import 'dart:typed_data';

/// Short TTL in-memory cache for [GET /api/get_user_profile] results (after avatar decode).
final class ProfileResponseCache {
  ProfileResponseCache({this.ttl = const Duration(seconds: 45)});

  final Duration ttl;
  Map<String, dynamic>? _entry;
  DateTime? _expiresAt;

  Future<Map<String, dynamic>> getOrFetch(
    Future<Map<String, dynamic>> Function() fetch,
  ) async {
    final now = DateTime.now();
    final cached = _entry;
    final exp = _expiresAt;
    if (cached != null && exp != null && now.isBefore(exp)) {
      return _copyForReturn(cached);
    }
    final fresh = await fetch();
    _entry = Map<String, dynamic>.from(fresh);
    _expiresAt = now.add(ttl);
    return _copyForReturn(fresh);
  }

  Map<String, dynamic> _copyForReturn(Map<String, dynamic> raw) {
    final avatar = raw['avatar'];
    final copiedAvatar = avatar is Uint8List ? Uint8List.fromList(avatar) : avatar;
    return <String, dynamic>{
      ...raw,
      'avatar': copiedAvatar,
    };
  }

  void invalidate() {
    _entry = null;
    _expiresAt = null;
  }
}
