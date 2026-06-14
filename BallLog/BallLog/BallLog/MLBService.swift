import Foundation
import Combine

class MLBService {
    static let shared = MLBService()
    private var cancellables = Set<AnyCancellable>()

    // 날짜 지정 경기 조회 (공통)
    func fetchGames(for date: Date, completion: @escaping (Result<[MLBGame], Error>) -> Void) {
        let dateStr = formatDate(date)
        let urlString = "https://statsapi.mlb.com/api/v1/schedule?sportId=1&date=\(dateStr)"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ScheduleResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                    print(" API 오류:", error)
                }
            }, receiveValue: { response in
                let games = response.dates.first?.games ?? []
                completion(.success(games))
            })
            .store(in: &cancellables)
    }

    // 오늘 경기 조회
    func fetchTodayGames(completion: @escaping (Result<[MLBGame], Error>) -> Void) {
        fetchGames(for: Date(), completion: completion)
    }

    // 어제 경기 조회
    func fetchYesterdayGames(completion: @escaping (Result<[MLBGame], Error>) -> Void) {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        fetchGames(for: yesterday, completion: completion)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
