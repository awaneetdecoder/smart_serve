class ApiEndpoints {
  static const String baseUrl = 'http://10.0.2.2:8080';

  // AUTH
  static const String register = '$baseUrl/api/auth/register';
  static const String login    = '$baseUrl/api/auth/login';

  // QUEUE
  static const String joinQueue   = '$baseUrl/api/queue/join';
  static const String userQueue   = '$baseUrl/api/queue/user';
  static const String allQueue    = '$baseUrl/api/queue/all';  // ← this was missing
  static const String queueStatus = '$baseUrl/api/queue';
}