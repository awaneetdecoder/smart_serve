class ApiEndpoints {
  static const String baseUrl = 'http://localhost:8080';

  // Auth
  static const String login = '$baseUrl/auth/login';

  // User Queue
  static const String generateToken = '$baseUrl/queue/token';
  static const String queueStatus = '$baseUrl/queue/status';

  // Admin
  static const String serveNext = '$baseUrl/admin/serve-next';
  static const String skipToken = '$baseUrl/admin/skip';
}
