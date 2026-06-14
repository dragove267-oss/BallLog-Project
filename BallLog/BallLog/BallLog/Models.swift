import Foundation

// MARK: - MLB API 모델
struct ScheduleResponse: Codable {
    let dates: [GameDate]
}

struct GameDate: Codable {
    let date: String
    let games: [MLBGame]
}

struct MLBGame: Codable {
    let gamePk: Int
    let gameDate: String
    let status: GameStatus
    let teams: GameTeams
}

struct GameStatus: Codable {
    let detailedState: String
}

struct GameTeams: Codable {
    let home: TeamInfo
    let away: TeamInfo
}

struct TeamInfo: Codable {
    let team: Team
    let score: Int?
}

struct Team: Codable {
    let id: Int
    let name: String
}

// MARK: - 예측 모델
struct Prediction: Codable, Identifiable {
    var id: UUID
    var gamePk: Int
    var gameDate: String
    var homeTeam: String
    var awayTeam: String
    var predictedTeam: String
    var actualWinner: String?
    var isCorrect: Bool?
}
