class PasswordResetOtpRequest {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirmation;

  PasswordResetOtpRequest({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}
