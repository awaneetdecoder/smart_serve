class TokenModel {
  final String id;
  final String tokenNumber; // "A-106"
  final String serviceName; // "General Consultation"
  final String status; // "WAITING", "SERVING"
  final int peopleAhead;
  final int estimatedWaitMinutes;

  TokenModel({
    required this.id,
    required this.tokenNumber,
    required this.serviceName,
    required this.status,
    required this.peopleAhead,
    required this.estimatedWaitMinutes,
  });

  // Factory for API parsing
  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      id: json['id'],
      tokenNumber: json['token_number'],
      serviceName: json['service_name'],
      status: json['status'],
      peopleAhead: json['people_ahead'],
      estimatedWaitMinutes: json['est_wait_mins'],
    );
  }
}