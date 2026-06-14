import UIKit

class YesterdayResultViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyLabel = UILabel()
    private var games: [MLBGame] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchYesterdayGames()
    }

    private func setupUI() {
        title = "어제 경기 결과"
        view.backgroundColor = .systemBackground

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GameCell.self, forCellReuseIdentifier: "GameCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        emptyLabel.text = "어제 경기 결과가 없습니다"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func fetchYesterdayGames() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
        emptyLabel.isHidden = true

        MLBService.shared.fetchYesterdayGames { [weak self] result in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()

            switch result {
            case .success(let games):
                self.games = games.filter { $0.status.detailedState == "Final" }
                if self.games.isEmpty {
                    self.emptyLabel.isHidden = false
                } else {
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
            case .failure:
                self.showErrorAlert()
            }
        }
    }

    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "오류",
            message: "경기 결과를 불러올 수 없습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "다시 시도", style: .default) { _ in
            self.fetchYesterdayGames()
        })
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        present(alert, animated: true)
    }
}

extension YesterdayResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
        cell.configure(with: games[indexPath.row])
        return cell
    }
}

extension YesterdayResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
