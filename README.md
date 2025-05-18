# devdino

## 프로젝트 개요

**devdino**는 여행 플래너 앱(Travelee)과 디자인 시스템(design_systems)을 포함한 모노레포 프로젝트입니다. Flutter 기반으로, 일관된 UI/UX와 확장성을 목표로 설계되었습니다.

---

## 주요 기능

### Travelee (여행 플래너)
- 여행 일정 생성, 수정, 삭제
- 여행 국가 및 기간 선택 (커스텀 캘린더)
- 여행별 상세 일정 관리 (Day별 데이터)
- 여행지별 국가 정보 및 플래그 표시
- 여행 데이터의 임시 저장 및 백업
- 광고 배너 노출
- Riverpod 기반 상태 관리
- GoRouter 기반 라우팅

### design_systems (디자인 시스템)
- DinoButton, DinoAppBar, DinoNaviBar 등 공통 UI 컴포넌트 제공
- 색상, 타이포그래피, 간격, 그림자 등 토큰 기반 스타일 관리
- 확장성과 재사용성을 고려한 컴포넌트 구조

---

## 폴더 구조

```
root/
├── apps/
│   └── travelee/           # 여행 플래너 앱
│       ├── lib/
│       │   ├── presentation/
│       │   ├── data/
│       │   ├── core/
│       │   └── providers/
│       └── assets/
├── design_systems/         # 공통 디자인 시스템 패키지
│   └── lib/dino/
│       ├── components/
│       └── foundations/
└── README.md
```

---

## 기술 스택
- Flutter 3.x
- Dart
- Riverpod (상태 관리)
- GoRouter (라우팅)
- Syncfusion DatePicker (캘린더)
- Country Picker (국가 선택)
- Freezed, JsonSerializable (모델)

---

## 빌드 및 실행 방법

1. 패키지 설치
   ```bash
   flutter pub get
   ```
2. 앱 실행
   ```bash
   flutter run -d [디바이스명]
   ```
3. 디자인 시스템만 테스트
   ```bash
   cd design_systems
   flutter test
   ```

---

## 기여 방법
- 이슈/버그/기능 제안은 GitHub Issue로 등록
- PR 제출 전, 코딩 컨벤션 및 린트 규칙 준수
- 커밋 메시지는 명확하게 작성

---

## 라이선스

MIT License