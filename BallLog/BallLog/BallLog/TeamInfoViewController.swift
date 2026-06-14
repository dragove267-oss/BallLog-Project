import UIKit

class TeamInfoViewController: UIViewController {

    let game: MLBGame
    private var awayRecord: TeamRecord?
    private var homeRecord: TeamRecord?
    private var headToHead: (wins: Int, losses: Int)?
    private var isLoading = true

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    init(game: MLBGame) {	
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchInfo()
    }

    private func setupUI() {
        title = "팀 정보"
        view.backgroundColor = .systemBackground

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        view.addSubview(tableView)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func fetchInfo() {
        activityIndicator.startAnimating()

        let group = DispatchGroup()

        // 순위 조회
        group.enter()
        TeamInfoService.shared.fetchStandings { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let records):
                self.awayRecord = records.first { $0.team.id == self.game.teams.away.team.id }
                self.homeRecord = records.first { $0.team.id == self.game.teams.home.team.id }
                print("✅ 어웨이 기록:", self.awayRecord?.wins ?? "없음")
                print("✅ 홈 기록:", self.homeRecord?.wins ?? "없음")
            case .failure(let error):
                print("❌ 순위 로딩 실패:", error)
            }
            group.leave()
        }

        // 상대전적 조회
        group.enter()
        TeamInfoService.shared.fetchHeadToHead(
            team1Id: game.teams.away.team.id,
            team2Id: game.teams.home.team.id
        ) { [weak self] result in
            if case .success(let h2h) = result {
                self?.headToHead = h2h
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            self.activityIndicator.stopAnimating()
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension TeamInfoViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "\(game.teams.away.team.name)  (원정)"
        case 1: return "\(game.teams.home.team.name)  (홈)"
        case 2: return "올 시즌 상대 전적"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1: return 3
        case 2: return 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.selectionStyle = .none

        switch indexPath.section {
        case 0:
            configureTeamCell(cell: cell, record: awayRecord, row: indexPath.row)
        case 1:
            configureTeamCell(cell: cell, record: homeRecord, row: indexPath.row)
        case 2:
            configureH2HCell(cell: cell)
        default: break
        }
        return cell
    }

    private func configureTeamCell(cell: UITableViewCell, record: TeamRecord?, row: Int) {
        // 로딩 중이거나 데이터 없을 때
        guard let record = record else {
            switch row {
            case 0:
                cell.textLabel?.text = "시즌 성적"
                cell.detailTextLabel?.text = isLoading ? "로딩 중..." : "데이터 없음"
            case 1:
                cell.textLabel?.text = "게임차"
                cell.detailTextLabel?.text = isLoading ? "로딩 중..." : "-"
            case 2:
                cell.textLabel?.text = "최근 흐름"
                cell.detailTextLabel?.text = isLoading ? "로딩 중..." : "-"
            default: break
            }
            cell.detailTextLabel?.textColor = .secondaryLabel
            return
        }

        switch row {
        case 0:
            cell.textLabel?.text = "시즌 성적"
            cell.detailTextLabel?.text = "\(record.wins)승 \(record.losses)패  (승률 \(record.winningPercentage))"
            cell.detailTextLabel?.textColor = .label

        case 1:
            cell.textLabel?.text = "게임차 (GB)"
            let gb = record.gamesBack == "-" ? "선두" : "\(record.gamesBack) 게임차"
            cell.detailTextLabel?.text = gb
            cell.detailTextLabel?.textColor = record.gamesBack == "-" ? .systemGreen : .label

        case 2:
            cell.textLabel?.text = "최근 흐름"
            let streakCode = record.streak?.streakCode ?? "-"
            cell.detailTextLabel?.text = streakCode
            let isWin = streakCode.hasPrefix("W")
            cell.detailTextLabel?.textColor = isWin ? .systemGreen : .systemRed

        default: break
        }
    }

    private func configureH2HCell(cell: UITableViewCell) {
        guard let h2h = headToHead else {
            cell.textLabel?.text = isLoading ? "로딩 중..." : "이번 시즌 맞대결 없음"
            cell.textLabel?.textColor = .secondaryLabel
            cell.textLabel?.textAlignment = .center
            return
        }

        let awayName = game.teams.away.team.name
        let homeName = game.teams.home.team.name
        let total = h2h.wins + h2h.losses

        if total == 0 {
            cell.textLabel?.text = "이번 시즌 맞대결 없음"
            cell.textLabel?.textColor = .secondaryLabel
        } else {
            cell.textLabel?.text = "\(awayName)  \(h2h.wins)승 \(h2h.losses)패  \(homeName)"
            cell.textLabel?.textColor = .label
        }
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = .systemFont(ofSize: 14, weight: .medium)
    }
}

// MARK: - UITableViewDelegate
extension TeamInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
}
