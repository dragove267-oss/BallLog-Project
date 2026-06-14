import Foundation

struct PointHistory: Codable, Identifiable {
    var id: UUID
    var date: Date
    var change: Int        // +10 or -5
    var reason: String     // "다저스 예측 적중" 등
    var totalAfter: Int    // 변동 후 총 포인트
}

class PointHistoryStore {
    static let shared = PointHistoryStore()
    private let key = "pointHistory"

    var histories: [PointHistory] {
        get { load() }
    }

    func add(change: Int, reason: String, total: Int) {
        var all = load()
        let history = PointHistory(
            id: UUID(),
            date: Date(),
            change: change,
            reason: reason,
            totalAfter: total
        )
        all.append(history)
        persist(all)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func load() -> [PointHistory] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([PointHistory].self, from: data)
        else { return [] }
        return decoded
    }

    private func persist(_ histories: [PointHistory]) {
        if let data = try? JSONEncoder().encode(histories) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
