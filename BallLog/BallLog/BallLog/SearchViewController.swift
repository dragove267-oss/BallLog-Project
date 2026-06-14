import UIKit

class SearchViewController: UIViewController {

    private let searchBar = UISearchBar()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let guideLabel = UILabel()

    private var searchResults: [MLBGame] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "경기 검색"
        view.backgroundColor = .systemBackground

        searchBar.placeholder = "팀 이름으로 검색 (예: Dodgers)"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GameCell.self, forCellReuseIdentifier: "GameCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        view.addSubview(tableView)

        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        guideLabel.text = "팀 이름을 입력하세요\n최근 7일간의 경기를 검색합니다"
        guideLabel.numberOfLines = 2
        guideLabel.textAlignment = .center
        guideLabel.textColor = .secondaryLabel
        guideLabel.font = .systemFont(ofSize: 14)
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(guideLabel)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // 최근 7일 경기 검색
    private func searchGames(query: String) {
        guard !query.isEmpty else { return }

        activityIndicator.startAnimating()
        tableView.isHidden = true
        guideLabel.isHidden = true
        searchResults = []

        let group = DispatchGroup()
        var allGames: [MLBGame] = []

        // 최근 7일 날짜 생성
        for dayOffset in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
            group.enter()
            MLBService.shared.fetchGames(for: date) { result in
                if case .success(let games) = result {
                    allGames.append(contentsOf: games)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()

            // 팀 이름으로 필터링 (대소문자 무시)
            self.searchResults = allGames.filter {
                $0.teams.home.team.name.lowercased().contains(query.lowercased()) ||
                $0.teams.away.team.name.lowercased().contains(query.lowercased())
            }
            // 날짜 최신순 정렬
            .sorted { $0.gameDate > $1.gameDate }

            if self.searchResults.isEmpty {
                self.guideLabel.text = "'\(query)' 검색 결과가 없습니다"
                self.guideLabel.isHidden = false
            } else {
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.isEmpty else { return }
        searchGames(query: query)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchResults = []
            tableView.isHidden = true
            guideLabel.text = "팀 이름을 입력하세요\n최근 7일간의 경기를 검색합니다"
            guideLabel.isHidden = false
            tableView.reloadData()
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
        cell.configure(with: searchResults[indexPath.row])
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let game = searchResults[indexPath.row]
        let vc = TeamInfoViewController(game: game)
        navigationController?.pushViewController(vc, animated: true)
    }
}
