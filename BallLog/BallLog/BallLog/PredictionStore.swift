import Foundation

class PredictionStore {
    static let shared = PredictionStore()
    private let key = "predictions"

    var predictions: [Prediction] {
        get { load() }
    }

    func save(_ prediction: Prediction) {
        var all = load()
        all.append(prediction)
        persist(all)
    }

    func update(_ prediction: Prediction) {
        var all = load()
        if let index = all.firstIndex(where: { $0.id == prediction.id }) {
            all[index] = prediction
            persist(all)
        }
    }

    func delete(_ prediction: Prediction) {
        var all = load()
        all.removeAll { $0.id == prediction.id }
        persist(all)
    }

    private func load() -> [Prediction] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Prediction].self, from: data)
        else { return [] }
        return decoded
    }

    private func persist(_ predictions: [Prediction]) {
        if let data = try? JSONEncoder().encode(predictions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}	
