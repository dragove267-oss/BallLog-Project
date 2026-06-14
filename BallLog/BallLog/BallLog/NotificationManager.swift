import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    // 알림 권한 요청
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print(" 알림 권한 허용")
            } else {
                print(" 알림 권한 거부")
            }
        }
    }

    // 경기 시작 1시간 전 알림 예약
    func scheduleGameNotification(game: MLBGame) {
        let formatter = ISO8601DateFormatter()
        guard let gameDate = formatter.date(from: game.gameDate) else { return }

        // 1시간 전
        let notifyDate = gameDate.addingTimeInterval(-3600)

        // 이미 지난 시간이면 예약 안 함
        guard notifyDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "⚾ 경기 시작 1시간 전!"
        content.body = "\(game.teams.away.team.name) vs \(game.teams.home.team.name) 곧 시작합니다!"
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notifyDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "game_\(game.gamePk)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 알림 예약 실패:", error)
            } else {
                print("✅ 알림 예약 완료: \(game.teams.away.team.name) vs \(game.teams.home.team.name)")
            }
        }
    }

    // 특정 경기 알림 취소
    func cancelNotification(gamePk: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["game_\(gamePk)"]
        )
    }

    // 예약된 알림 목록 확인
    func checkScheduledNotifications(completion: @escaping ([String]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let ids = requests.map { $0.identifier }
            completion(ids)
        }
    }
}
