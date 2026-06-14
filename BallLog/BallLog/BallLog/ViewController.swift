import UIKit

class ViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyLabel = UILabel()
    private let filterSegment = UISegmentedControl(items: ["전체", "즐겨찾기"])

    private var allGames: [MLBGame] = []
    private var filteredGames: [MLBGame] = [] {
        didSet { tableView.reloadData() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationManager.shared.requestPermission()
        fetchGames()
    }

    private func setupUI() {
        title = "오늘의 경기"
        view.backgroundColor = .systemBackground

        // 세그먼트 컨트롤
        filterSegment.selectedSegmentIndex = 0
        filterSegment.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        filterSegment.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterSegment)

        // 즐겨찾기 버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: FavoriteTeamStore.shared.favoriteTeamId != nil ? "star.fill" : "star"),
            style: .plain,
            target: self,
            action: #selector(showFavoriteTeamPicker)
        )

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GameCell.self, forCellReuseIdentifier: "GameCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        emptyLabel.text = "오늘 예정된 경기가 없습니다"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            filterSegment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            filterSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: filterSegment.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func fetchGames() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
        emptyLabel.isHidden = true

        MLBService.shared.fetchTodayGames { [weak self] result in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()

            switch result {
            case .success(let games):
                self.allGames = games
                self.applyFilter()
                if self.filteredGames.isEmpty {
                    self.emptyLabel.isHidden = false
                } else {
                    self.tableView.isHidden = false
                }
            case .failure:
                self.showErrorAlert()
            }
        }
    }

    private func applyFilter() {
        if filterSegment.selectedSegmentIndex == 1,
           let favoriteId = FavoriteTeamStore.shared.favoriteTeamId {
            filteredGames = allGames.filter {
                $0.teams.home.team.id == favoriteId ||
                $0.teams.away.team.id == favoriteId
            }
        } else {
            filteredGames = allGames
        }
    }

    @objc private func filterChanged() {
        applyFilter()
        emptyLabel.isHidden = !filteredGames.isEmpty
        tableView.isHidden = filteredGames.isEmpty
    }

    @objc private func showFavoriteTeamPicker() {
        guard !allGames.isEmpty else {
            let alert = UIAlertController(title: "안내", message: "경기 목록을 먼저 불러와주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }

        var teams: [(id: Int, name: String)] = []
        for game in allGames {
            let home = (id: game.teams.home.team.id, name: game.teams.home.team.name)
            let away = (id: game.teams.away.team.id, name: game.teams.away.team.name)
            if !teams.contains(where: { $0.id == home.id }) { teams.append(home) }
            if !teams.contains(where: { $0.id == away.id }) { teams.append(away) }
        }
        teams.sort { $0.name < $1.name }

        let alert = UIAlertController(title: "즐겨찾기 팀 선택",
                                      message: "경기 필터링에 사용됩니다",
                                      preferredStyle: .actionSheet)
        for team in teams {
            let isFav = FavoriteTeamStore.shared.isFavorite(teamId: team.id)
            let title = isFav ? "⭐ \(team.name)" : team.name
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                FavoriteTeamStore.shared.setFavoriteTeam(id: team.id, name: team.name)
                self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star.fill")
                self.applyFilter()
            })
        }
        alert.addAction(UIAlertAction(title: "즐겨찾기 해제", style: .destructive) { _ in
            FavoriteTeamStore.shared.clearFavoriteTeam()
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star")
            self.applyFilter()
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    private func showErrorAlert() {
        let alert = UIAlertController(title: "오류",
                                      message: "경기 정보를 불러올 수 없습니다.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "다시 시도", style: .default) { _ in self.fetchGames() })
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
        cell.configure(with: filteredGames[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let game = filteredGames[indexPath.row]

        let alert = UIAlertController(
            title: "\(game.teams.away.team.name) vs \(game.teams.home.team.name)",
            message: "무엇을 하시겠습니까?",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: " 승부 예측하기", style: .default) { _ in
            let vc = PredictionInputViewController(game: game)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        alert.addAction(UIAlertAction(title: " 팀 정보 보기", style: .default) { _ in
            let vc = TeamInfoViewController(game: game)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        alert.addAction(UIAlertAction(title: " 경기 알림 설정", style: .default) { _ in
            NotificationManager.shared.scheduleGameNotification(game: game)
            let confirm = UIAlertController(
                title: " 알림 설정 완료",
                message: "경기 시작 1시간 전에 알려드릴게요!",
                preferredStyle: .alert
            )
            confirm.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(confirm, animated: true)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
