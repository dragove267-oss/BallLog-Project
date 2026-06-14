import Foundation
import UIKit

struct Level {
    let name: String
    let emoji: String
    let minPoints: Int
    let maxPoints: Int
    let color: UIColor
}

class LevelManager {
    static let shared = LevelManager()

    let levels: [Level] = [
        Level(name: "Bronze",   emoji: "🥉", minPoints: 0,   maxPoints: 50,
              color: UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)),   // 브라운
        Level(name: "Silver", emoji: "🥈", minPoints: 51,  maxPoints: 150,
              color: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)),   // 실버
        Level(name: "Gold",   emoji: "🥇", minPoints: 151, maxPoints: 300,
              color: UIColor(red: 0.9, green: 0.7, blue: 0.0, alpha: 1.0)),   // 골드
        Level(name: "Diamond", emoji: "💎", minPoints: 301, maxPoints: 500,
              color: UIColor(red: 0.0, green: 0.5, blue: 0.9, alpha: 1.0)),   // 블루
        Level(name: "Champion", emoji: "👑", minPoints: 501, maxPoints: Int.max,
              color: UIColor(red: 0.6, green: 0.0, blue: 0.9, alpha: 1.0)),   // 퍼플
    ]

    func currentLevel(points: Int) -> Level {
        return levels.last(where: { points >= $0.minPoints }) ?? levels[0]
    }

    func nextLevel(points: Int) -> Level? {
        let current = currentLevel(points: points)
        return levels.first(where: { $0.minPoints > current.minPoints })
    }

    func progressToNextLevel(points: Int) -> Float {
        let current = currentLevel(points: points)
        guard let next = nextLevel(points: points) else { return 1.0 }
        let range = next.minPoints - current.minPoints
        let progress = points - current.minPoints
        return Float(progress) / Float(range)
    }

    func pointsToNextLevel(points: Int) -> Int? {
        guard let next = nextLevel(points: points) else { return nil }
        return next.minPoints - points
    }
}
