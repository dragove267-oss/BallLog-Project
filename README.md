# BallLog 

나만의 야구 경기 기록 & 승패 예측 iOS 앱

 주요 기능

| 기능 | 설명 |
|------|------|
| 오늘 경기 | MLB 실시간 경기 일정 조회 |
| 어제 결과 | 전날 경기 결과 확인 |
| 승부 예측 | 경기 결과 예측 & 적중률 통계 |
| 포인트 시스템 | 예측 적중 시 포인트 누적 & 레벨업 |
| 팀 정보 | 시즌 성적, 상대 전적 조회 |
| 경기 검색 | 팀 이름으로 최근 경기 검색 |
| 알림 | 경기 시작 1시간 전 푸시 알림 |
| 즐겨찾기 | 관심 팀 필터링 |

 기술 스택

| 구분 | 내용 |
|------|------|
| 언어 | Swift |
| UI | UIKit |
| 데이터 저장 | UserDefaults + Codable |
| 네트워크 | URLSession + Combine |
| API | MLB Stats API |
| 개발 환경 | Xcode 12.5 

##  프로젝트 구조

\`\`\`
BallLog/
├── Models/
│   └── Models.swift
├── Services/
│   ├── MLBService.swift
│   ├── TeamInfoService.swift
│   └── NotificationManager.swift
├── Stores/
│   ├── PredictionStore.swift
│   ├── PointStore.swift
│   ├── PointHistoryStore.swift
│   └── FavoriteTeamStore.swift
├── ViewControllers/
│   ├── ViewController.swift
│   ├── YesterdayResultViewController.swift
│   ├── PredictionHistoryViewController.swift
│   ├── PredictionInputViewController.swift
│   ├── TeamInfoViewController.swift
│   └── SearchViewController.swift
├── Views/
│   └── GameCell.swift
└── Utils/
    └── LevelManager.swift
\`\`\`

## 실행 방법

\`\`\`
1. 레포 클론
git clone https://github.com/본인아이디/BallLog.git

2. Xcode 12.5 이상에서 열기
open BallLog.xcodeproj

3. 시뮬레이터 또는 실기기에서 실행
\`\`\`

## 포인트 레벨 시스템

| 레벨 | 포인트 |
|------|--------|
| 🥉 브론즈 | 0 ~ 50점 |
| 🥈 실버 | 51 ~ 150점 |
| 🥇 주전 | 151 ~ 300점 |
| 💎 올스타 | 301 ~ 500점 |
| 👑 레전드 | 501점 이상 |

## 스크린샷
<!-- 시연 영상 및 스크린샷 추가 예정 -->

## 사용 API
- [MLB Stats API](https://statsapi.mlb.com)
