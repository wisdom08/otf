import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Auth Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SignInWithGoogle extends AuthEvent {}

class SignOut extends AuthEvent {}

// Auth States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  final String name;

  const AuthAuthenticated({
    required this.userId,
    required this.email,
    required this.name,
  });

  @override
  List<Object> get props => [userId, email, name];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// Auth Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignOut>(_onSignOut);
  }

  void _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // TODO: 실제 인증 상태 확인 로직 구현
      // 임시로 인증되지 않은 상태로 설정
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('인증 상태 확인 중 오류가 발생했습니다.'));
    }
  }

  void _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // TODO: 실제 Google 로그인 로직 구현
      // 임시로 성공한 것으로 처리
      await Future.delayed(const Duration(seconds: 2));

      emit(
        const AuthAuthenticated(
          userId: 'temp_user_id',
          email: 'user@example.com',
          name: '사용자',
        ),
      );
    } catch (e) {
      emit(AuthError('Google 로그인 중 오류가 발생했습니다.'));
    }
  }

  void _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // TODO: 실제 로그아웃 로직 구현
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('로그아웃 중 오류가 발생했습니다.'));
    }
  }
}
