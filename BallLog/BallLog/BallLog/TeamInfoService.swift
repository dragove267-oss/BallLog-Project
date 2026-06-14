import Foundation
import Combine

// MARK: - 순위 모델 (실제 API 구조)
struct StandingsResponse: Codable {
    let records: [DivisionRecord]
}

struct DivisionRecord: Codable {
    let teamRecords: [TeamRecord]
}

struct TeamRecord: Codable {
    let team: TeamBasic
    let wins: Int
    let losses: Int
    let winningPercentage: String
    let gamesBack: String
    let streak: Streak?
    let divisionRank: String?

    enum CodingKeys: String, CodingKey {
        case team, wins, losses
        case winningPercentage
        case gamesBack
        case streak
        case divisionRank
    }
}

struct TeamBasic: Codable {
    let id: Int
    let name: String
}

struct Streak: Codable {
    let streakCode: String?
}

// MARK: - 상대전적 모델
struct HeadToHeadResponse: Codable {
    let dates: [H2HDate]
}

struct H2HDate: Codable {
    let games: [H2HGame]
}

struct H2HGame: Codable {
    let gamePk: Int
    let status: H2HStatus
    let teams: H2HTeams
}

struct H2HStatus: Codable {
    let detailedState: String
}

struct H2HTeams: Codable {
    let home: H2HTeamInfo
    let away: H2HTeamInfo
}

struct H2HTeamInfo: Codable {
    let team: TeamBasic
    let score: Int?
}

// MARK: - 서비스
class TeamInfoService {
    static let shared = TeamInfoService()
    private var cancellables = Set<AnyCancellable>()

    func fetchStandings(completion: @escaping (Result<[TeamRecord], Error>) -> Void) {
        let year = Calendar.current.component(.year, from: Date())
        let urlString = "https://statsapi.mlb.com/api/v1/standings?leagueId=103,104&season=\(year)&standingsTypes=regularSeason"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else { return }

            // 콘솔에서 실제 응답 확인
            if let json = String(data: data, encoding: .utf8) {
                print("📦 Standings 응답 앞부분:", String(json.prefix(800)))
            }

            do {
                let response = try JSONDecoder().decode(StandingsResponse.self, from: data)
                let allRecords = response.records.flatMap { $0.teamRecords }
                print("✅ 팀 수:", allRecords.count)
                allRecords.forEach { print("  팀:", $0.team.id, $0.team.name) }
                DispatchQueue.main.async { completion(.success(allRecords)) }
            } catch {
                print("❌ 디코딩 오류:", error)
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    func fetchHeadToHead(team1Id: Int, team2Id: Int,
                         completion: @escaping (Result<(wins: Int, losses: Int), Error>) -> Void) {
        let year = Calendar.current.component(.year, from: Date())
        let urlString = "https://statsapi.mlb.com/api/v1/schedule?sportId=1&season=\(year)&teamId=\(team1Id)&opponentId=\(team2Id)&gameType=R"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else { return }

            do {
                let response = try JSONDecoder().decode(HeadToHeadResponse.self, from: data)
                let games = response.dates.flatMap { $0.games }
                    .filter { $0.status.detailedState == "Final" }

                var wins = 0
                var losses = 0
                for game in games {
                    guard let homeScore = game.teams.home.score,
                          let awayScore = game.teams.away.score else { continue }
                    let team1IsHome = game.teams.home.team.id == team1Id
                    let team1Score = team1IsHome ? homeScore : awayScore
                    let team2Score = team1IsHome ? awayScore : homeScore
                    if team1Score > team2Score { wins += 1 } else { losses += 1 }
                }
                DispatchQueue.main.async { completion(.success((wins: wins, losses: losses))) }
            } catch {
                print("❌ H2H 디코딩 오류:", error)
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}
