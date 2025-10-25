# OTF - One Thing First

## 📱 프로젝트 개요
"하루에 하나라도, 제대로. 그리고 친구와 함께 보면 더 즐겁다."

OTF는 개인 목표 관리와 친구와의 공유를 통해 동기부여를 높이는 Flutter 앱입니다.

## 🏗️ 아키텍처
- **Clean Architecture** + **BLoC Pattern**
- **Drift** (SQLite) 데이터베이스
- **GetIt** 의존성 주입
- **Firebase** 인증 및 푸시 알림

## 📦 주요 패키지
- `flutter_bloc`: 상태 관리
- `drift`: 로컬 데이터베이스
- `firebase_auth`: 인증
- `google_sign_in`: 구글 로그인
- `flutter_screenutil`: 반응형 UI
- `google_fonts`: 폰트
- `lottie`: 애니메이션
- `fl_chart`: 차트

## 🚀 실행 방법

1. **패키지 설치**
```bash
flutter pub get
```

2. **코드 생성** (Drift, JSON Serialization)
```bash
flutter packages pub run build_runner build
```

3. **앱 실행**
```bash
flutter run
```

## 📁 프로젝트 구조
```
lib/
├── core/                    # 핵심 공통 기능
│   ├── constants/           # 상수 정의
│   ├── errors/              # 에러 처리
│   ├── network/             # 네트워크 설정
│   ├── theme/               # 테마 설정
│   └── di/                  # 의존성 주입
├── data/                    # 데이터 레이어
│   ├── database/            # 데이터베이스 설정
│   ├── models/              # 데이터 모델
│   └── repositories/        # 리포지토리 구현
├── domain/                  # 도메인 레이어
│   ├── entities/            # 비즈니스 엔티티
│   ├── repositories/        # 리포지토리 인터페이스
│   └── usecases/           # 유스케이스
└── presentation/            # 프레젠테이션 레이어
    ├── bloc/                # BLoC 상태 관리
    ├── pages/               # 화면
    ├── widgets/             # 재사용 가능한 위젯
    └── routes/              # 라우팅
```

## 🎯 주요 기능
- ✅ 목표 설정 (월간/주간/일간)
- ✅ 목표 진행 및 완료 추적
- ✅ 회고 작성 (한 줄/KPT/이모지)
- ✅ 친구와 목표/회고 공유
- ✅ Streak 및 월간 리포트
- ✅ 푸시 알림

## 🔧 개발 환경
- Flutter 3.8.1+
- Dart 3.0+
- Android Studio / VS Code
- Firebase Console

## 📝 TODO
- [ ] Firebase 프로젝트 설정
- [ ] 실제 인증 로직 구현
- [ ] 데이터베이스 CRUD 구현
- [ ] 목표 관리 기능 구현
- [ ] 회고 작성 기능 구현
- [ ] 친구 피드 기능 구현
- [ ] 푸시 알림 구현
- [ ] 테스트 코드 작성