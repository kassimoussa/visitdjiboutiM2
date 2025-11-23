class AuthResponse {
  final Map<String, dynamic> user;
  final String token;
  final String tokenType;

  AuthResponse({
    required this.user,
    required this.token,
    required this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: json['user'] ?? {},
      token: json['token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
    );
  }
}
