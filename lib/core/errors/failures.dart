import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}

// 일반적인 실패
class GeneralFailure extends Failure {
  const GeneralFailure([super.message]);
}

// 네트워크 관련 실패
class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message]);
}

// 인증 관련 실패
class AuthFailure extends Failure {
  const AuthFailure([super.message]);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message]);
}

// 데이터베이스 관련 실패
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

// 권한 관련 실패
class PermissionFailure extends Failure {
  const PermissionFailure([super.message]);
}

// 유효성 검사 실패
class ValidationFailure extends Failure {
  const ValidationFailure([super.message]);
}

// 파일 관련 실패
class FileFailure extends Failure {
  const FileFailure([super.message]);
}

// 알림 관련 실패
class NotificationFailure extends Failure {
  const NotificationFailure([super.message]);
}
