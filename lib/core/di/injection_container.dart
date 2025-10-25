import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'data/database/app_database.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/goal_repository_impl.dart';
import 'data/repositories/daily_task_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/goal_repository.dart';
import 'domain/repositories/daily_task_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/goal/goal_bloc.dart';
import 'presentation/bloc/daily_task/daily_task_bloc.dart';

part 'injection_container.g.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // 데이터베이스
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // 리포지토리
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<GoalRepository>(
    () => GoalRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<DailyTaskRepository>(
    () => DailyTaskRepositoryImpl(getIt()),
  );

  // BLoC
  getIt.registerFactory<AuthBloc>(() => AuthBloc());
  getIt.registerFactory<GoalBloc>(() => GoalBloc(getIt()));
  getIt.registerFactory<DailyTaskBloc>(() => DailyTaskBloc(getIt()));
}

// 임시 리포지토리 구현체들 (실제 구현 필요)
class AuthRepositoryImpl implements AuthRepository {
  final AppDatabase _database;

  AuthRepositoryImpl(this._database);

  @override
  Future<bool> isAuthenticated() async {
    // TODO: 실제 구현
    return false;
  }

  @override
  Future<String?> signInWithGoogle() async {
    // TODO: 실제 구현
    return null;
  }

  @override
  Future<void> signOut() async {
    // TODO: 실제 구현
  }
}

class GoalRepositoryImpl implements GoalRepository {
  final AppDatabase _database;

  GoalRepositoryImpl(this._database);

  @override
  Future<List<GoalModel>> getGoals(String userId) async {
    // TODO: 실제 구현
    return [];
  }

  @override
  Future<void> createGoal(GoalModel goal) async {
    // TODO: 실제 구현
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    // TODO: 실제 구현
  }

  @override
  Future<void> deleteGoal(int goalId) async {
    // TODO: 실제 구현
  }
}

class DailyTaskRepositoryImpl implements DailyTaskRepository {
  final AppDatabase _database;

  DailyTaskRepositoryImpl(this._database);

  @override
  Future<List<DailyTaskModel>> getDailyTasks(
    String userId,
    DateTime date,
  ) async {
    // TODO: 실제 구현
    return [];
  }

  @override
  Future<void> createDailyTask(DailyTaskModel task) async {
    // TODO: 실제 구현
  }

  @override
  Future<void> updateDailyTask(DailyTaskModel task) async {
    // TODO: 실제 구현
  }

  @override
  Future<void> completeTask(int taskId) async {
    // TODO: 실제 구현
  }
}

// 임시 인터페이스들 (실제 구현 필요)
abstract class AuthRepository {
  Future<bool> isAuthenticated();
  Future<String?> signInWithGoogle();
  Future<void> signOut();
}

abstract class GoalRepository {
  Future<List<GoalModel>> getGoals(String userId);
  Future<void> createGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(int goalId);
}

abstract class DailyTaskRepository {
  Future<List<DailyTaskModel>> getDailyTasks(String userId, DateTime date);
  Future<void> createDailyTask(DailyTaskModel task);
  Future<void> updateDailyTask(DailyTaskModel task);
  Future<void> completeTask(int taskId);
}
