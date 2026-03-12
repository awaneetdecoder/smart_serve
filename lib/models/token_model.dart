import 'dart:isolate';

import 'user_model.dart';
class TokenModel {
  final int  id;
  final String tokenNumber; // "A-106"
  final String tokenType; // "General Consultation"
  final String status; // "WAITING", "SERVING"
  final bool isDeleted;
  final String createdAt;
  final UserModel? user; // Optional user details
  final int peopleAhead; // Number of people ahead in the queue
  final int estimatedWaitMinutes; // Estimated wait time in minutes

  TokenModel({
    required this.id,
    required this.tokenNumber,
    required this.tokenType,
    required this.status,
    this.isDeleted = false,
    this.createdAt = '',
    this.user,    
    this.peopleAhead=0,
    this.estimatedWaitMinutes=0,
  });

  // Factory for API parsing
  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      id: json['id'] ?? 0,
      tokenNumber: json['tokenNumber'] ?? 'Unknown',
      tokenType: json['tokenType'] ?? 'General ',
      status: json['status'] ?? 'WAITING',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt']?.toString() ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null  ,
    );
  }

  TokenModel copyWith({
    
    int? peopleAhead,
    int? estimatedWaitMinutes,
    String? status,
  }) {
    return TokenModel(
      id: id,
      tokenNumber: tokenNumber,
      tokenType: tokenType,
      status: status ?? this.status,
      isDeleted: isDeleted,
      createdAt: createdAt,
      user: user, // Keep the same user details
      peopleAhead: peopleAhead ?? this.peopleAhead,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
    );
  }

  bool get isActive => status.toUpperCase() == 'WAITING';
  bool get isServing => status.toUpperCase() == 'SERVING';
  bool get isCancelled => status.toUpperCase() == 'CANCELLED';

  @override
  String toString() => 'TokenModel(#$tokenNumber, status:$status)';
}