/// Exception khusus untuk error koneksi database (MySQL Offline / Unreachable).
///
/// Dilempar ketika koneksi ke MySQL server gagal (mis. SocketException),
/// sehingga UI layer dapat membedakan antara:
/// - [DatabaseOfflineException] → server tidak bisa dijangkau
/// - `null` return / logika lain  → data tidak valid / kredensial salah
class DatabaseOfflineException implements Exception {
  final String message;
  final Object? originalError;

  const DatabaseOfflineException({
    required this.message,
    this.originalError,
  });

  /// Cek apakah suatu exception adalah error koneksi jaringan
  static bool isConnectionError(Object err) {
    final msg = err.toString().toLowerCase();
    return msg.contains('socketexception') ||
        msg.contains('refused') ||
        msg.contains('errno = 1225') ||
        msg.contains('connection refused') ||
        msg.contains('network is unreachable') ||
        msg.contains('connection timed out') ||
        msg.contains('osrror') ||
        msg.contains('the remote computer');
  }

  @override
  String toString() => 'DatabaseOfflineException: $message';
}
