import Foundation

class FavoriteTeamStore {
    static let shared = FavoriteTeamStore()
    private let key = "favoriteTeamId"
    private let nameKey = "favoriteTeamName"

    var favoriteTeamId: Int? {
        get {
            let id = UserDefaults.standard.integer(forKey: key)
            return id == 0 ? nil : id
        }
        set {
            UserDefaults.standard.set(newValue ?? 0, forKey: key)
        }
    }

    var favoriteTeamName: String? {
        get { UserDefaults.standard.string(forKey: nameKey) }
        set { UserDefaults.standard.set(newValue, forKey: nameKey) }
    }

    func setFavoriteTeam(id: Int, name: String) {
        favoriteTeamId = id
        favoriteTeamName = name
    }

    func clearFavoriteTeam() {
        favoriteTeamId = nil
        favoriteTeamName = nil
    }

    func isFavorite(teamId: Int) -> Bool {
        return favoriteTeamId == teamId
    }
}
