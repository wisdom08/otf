import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// 사용자 테이블
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  TextColumn get profileImage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 목표 테이블 (계층 구조)
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text()(); // 'monthly', 'weekly', 'daily'
  IntColumn get parentId => integer().nullable().references(Goals, #id)();
  TextColumn get userId => text().references(Users, #id)();
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();
  TextColumn get visibility => text().withDefault(
    const Constant('private'),
  )(); // 'public', 'friends', 'private'
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

// 일간 할 일 테이블
class DailyTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().references(Goals, #id)();
  TextColumn get userId => text().references(Users, #id)();
  DateColumn get date => date()();
  DateTimeColumn get startTime => dateTime().nullable()();
  DateTimeColumn get endTime => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

// 회고 테이블
class Reflections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(DailyTasks, #id)();
  TextColumn get type => text()(); // 'text', 'kpt', 'emoji'
  TextColumn get content => text().nullable()();
  TextColumn get keep => text().nullable()();
  TextColumn get problem => text().nullable()();
  TextColumn get tryText => text().nullable()();
  IntColumn get emojiScore => integer().nullable()(); // 1-5
  DateTimeColumn get createdAt => dateTime()();
}

// 연속 달성 테이블
class Streaks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().references(Users, #id)();
  DateColumn get startDate => date()();
  IntColumn get count => integer()();
  DateColumn get lastUpdated => date()();
}

// 친구 관계 테이블
class Friends extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get friendUserId => text().references(Users, #id)();
  TextColumn get status => text()(); // 'pending', 'accepted', 'blocked'
  DateTimeColumn get createdAt => dateTime()();
}

// 피드 테이블
class Feeds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().references(Users, #id)();
  IntColumn get taskId => integer().references(DailyTasks, #id).nullable()();
  IntColumn get reflectionId =>
      integer().references(Reflections, #id).nullable()();
  TextColumn get visibility => text()(); // 'public', 'friends', 'private'
  DateTimeColumn get createdAt => dateTime()();
}

// 댓글/응원 테이블
class Comments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get feedId => integer().references(Feeds, #id)();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get content => text().nullable()();
  TextColumn get emojiType => text().nullable()(); // 👍 ❤️ 💪 🌟
  DateTimeColumn get createdAt => dateTime()();
}

// 알림 테이블
class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get type => text()(); // 'goal_completed', 'comment', 'reaction'
  TextColumn get title => text()();
  TextColumn get message => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(
  tables: [
    Users,
    Goals,
    DailyTasks,
    Reflections,
    Streaks,
    Friends,
    Feeds,
    Comments,
    Notifications,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'otf.db'));
    return NativeDatabase(file);
  });
}
