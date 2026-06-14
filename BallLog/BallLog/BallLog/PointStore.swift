import Foundation

class PointStore {
    static let shared = PointStore()
    private let key = "userPoints"

    var points: Int {
        get { UserDefaults.standard.integer(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    func addPoint(reason: String) {
        points += 10
        PointHistoryStore.shared.add(change: +10, reason: reason, total: points)
    }

    func deductPoint(reason: String) {
        points = max(0, points - 5)
        PointHistoryStore.shared.add(change: -5, reason: reason, total: points)
    }

    func reset() {
        points = 0
        PointHistoryStore.shared.clear()
    }
}
