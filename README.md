# BallLog 

나만의 야구 경기 기록 & 승패 예측 iOS 앱


##  프로젝트 정의

BallLog는 MLB 실시간 경기 정보를 기반으로  
경기 결과를 예측하고 포인트를 쌓는 **야구 팬 전용 iOS 앱**입니다.


##  목적

- 야구 팬이 경기 정보를 한 곳에서 확인할 수 있도록 한다
- 경기 결과 예측을 통해 야구 시청의 몰입감을 높인다
- 포인트 & 레벨 시스템으로 지속적인 참여를 유도한다


##  기획 배경

야구를 즐기는 팬들은 두 가지 불편함을 겪고 있습니다.

> **1**, 경기 결과를 예측하며 재미를 즐기고 싶어도  
> 기록이 남지 않아 금방 잊혀집니다.

> **2**, 경기 일정, 팀 정보, 예측을 한 번에 볼 수 있는  
> 통합 앱이 없어 여러 앱을 번갈아 사용해야 합니다.

BallLog는 이 두 가지 불편함을 하나의 앱으로 해결합니다.


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
<img width="398" height="517" alt="image" src="https://github.com/user-attachments/assets/c73cdd24-0e1b-453c-ba5e-7406e12fbd70" />

\`\`\`



## 포인트 레벨 시스템

| 레벨 | 포인트 |
|------|--------|
| 🥉 브론즈 | 0 ~ 50점 |
| 🥈 실버 | 51 ~ 150점 |
| 🥇 골드 | 151 ~ 300점 |
| 💎 다이아몬드 | 301 ~ 500점 |
| 👑 챔피언 | 501점 이상 |


## 결과물

###  오늘의 경기
<img width="373" height="652" alt="오늘의 경기" src="https://github.com/user-attachments/assets/02341d45-a042-49e3-8196-24a05989a471" />

###  즐겨찾기
<img width="374" height="652" alt="즐겨찾기" src="https://github.com/user-attachments/assets/6632f1e0-c17e-4272-975b-6b356e7e3ff2" />

###  예측
<table>
  <tr>
    <td><img width="371" alt="예측화면1" src="https://github.com/user-attachments/assets/159b1c51-ed3a-4a89-884a-4657264b0e84" /></td>
    <td><img width="371" alt="예측화면2" src="https://github.com/user-attachments/assets/4847675e-877c-448b-9e75-6e2774cd1075" /></td>
  </tr>
</table>

###  검색
<img width="373" height="650" alt="검색화면" src="https://github.com/user-attachments/assets/7f4feb7f-7ed1-4f21-8fc4-d05981976282" />

## 시연 영상
<!-- 시연 영상 및 스크린샷 추가 예정 -->
https://www.youtube.com/watch?v=Ivr9CuO-raY
## 사용 API
- [MLB Stats API](https://statsapi.mlb.com)
