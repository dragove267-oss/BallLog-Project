import UIKit

class PredictionHistoryViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let segmentControl = UISegmentedControl(items: ["예측 목록", "포인트 내역"])
    private var predictions: [Prediction] = []
    private var pointHistories: [PointHistory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        predictions = PredictionStore.shared.predictions.reversed()
        pointHistories = PointHistoryStore.shared.histories.reversed()
        tableView.reloadData()
    }

    private func setupUI() {
        title = "예측"
        view.backgroundColor = .systemBackground

        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentControl)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func segmentChanged() {
        tableView.reloadData()
    }

    private func showResultInput(for prediction: Prediction) {
        let alert = UIAlertController(
            title: "결과 입력",
            message: "\(prediction.awayTeam) vs \(prediction.homeTeam)\n실제 승리 팀을 선택하세요",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: prediction.awayTeam, style: .default) { _ in
            self.updateResult(for: prediction, winner: prediction.awayTeam)
        })
        alert.addAction(UIAlertAction(title: prediction.homeTeam, style: .default) { _ in
            self.updateResult(for: prediction, winner: prediction.homeTeam)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    private func updateResult(for prediction: Prediction, winner: String) {
        var updated = prediction
        updated.actualWinner = winner
        updated.isCorrect = (winner == prediction.predictedTeam)

        let reason = "\(prediction.awayTeam) vs \(prediction.homeTeam)"
        if updated.isCorrect == true {
            PointStore.shared.addPoint(reason: "\(reason) 적중")
            showPointAlert(correct: true)
        } else {
            PointStore.shared.deductPoint(reason: "\(reason) 실패")
            showPointAlert(correct: false)
        }

        PredictionStore.shared.update(updated)
        predictions = PredictionStore.shared.predictions.reversed()
        pointHistories = PointHistoryStore.shared.histories.reversed()
        tableView.reloadData()
    }

    private func showPointAlert(correct: Bool) {
        let level = LevelManager.shared.currentLevel(points: PointStore.shared.points)
        let title = correct ? "✅ 예측 적중!" : "❌ 예측 실패"
        let message = correct
            ? "+10점 획득!\n현재 포인트: \(PointStore.shared.points)점\n등급: \(level.emoji) \(level.name)"
            : "-5점 차감\n현재 포인트: \(PointStore.shared.points)점\n등급: \(level.emoji) \(level.name)"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - UITableViewDataSource
extension PredictionHistoryViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return segmentControl.selectedSegmentIndex == 0 ? 3 : 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segmentControl.selectedSegmentIndex == 0 {
            switch section {
            case 0: return "내 포인트 & 레벨"
            case 1: return "예측 통계"
            case 2: return "예측 목록"
            default: return nil
            }
        } else {
            switch section {
            case 0: return "현재 포인트"
            case 1: return "포인트 변동 내역"
            default: return nil
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentControl.selectedSegmentIndex == 0 {
            switch section {
            case 0: return 2  // 레벨 + 진행도
            case 1: return 1
            case 2: return predictions.isEmpty ? 1 : predictions.count
            default: return 0
            }
        } else {
            switch section {
            case 0: return 1
            case 1: return pointHistories.isEmpty ? 1 : pointHistories.count
            default: return 0
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.selectionStyle = .none

        if segmentControl.selectedSegmentIndex == 0 {
            switch indexPath.section {
            case 0:
                let level = LevelManager.shared.currentLevel(points: PointStore.shared.points)
                let toNext = LevelManager.shared.pointsToNextLevel(points: PointStore.shared.points)
                let progress = LevelManager.shared.progressToNextLevel(points: PointStore.shared.points)

                if indexPath.row == 0 {
                    // 레벨 + 포인트
                    cell.textLabel?.text = "\(level.emoji) \(level.name)"
                    cell.textLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
                    cell.detailTextLabel?.text = "\(PointStore.shared.points)점"
                    cell.detailTextLabel?.font = .systemFont(ofSize: 15, weight: .bold)
                    cell.detailTextLabel?.textColor = level.color
                } else {
                    // 다음 레벨 진행도 바
                    let progressBar = UIProgressView(progressViewStyle: .default)
                    progressBar.progress = progress
                    progressBar.tintColor = level.color
                    progressBar.trackTintColor = .systemGray5
                    progressBar.translatesAutoresizingMaskIntoConstraints = false
                    cell.contentView.addSubview(progressBar)

                    cell.textLabel?.text = toNext != nil ? "다음 레벨까지 \(toNext!)점" : "👑 최고 레벨 달성!"
                    cell.textLabel?.font = .systemFont(ofSize: 13)
                    cell.textLabel?.textColor = .secondaryLabel

                    NSLayoutConstraint.activate([
                        progressBar.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                        progressBar.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                        progressBar.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10),
                    ])
                }

            case 1:
                let total = predictions.count
                let correct = predictions.filter { $0.isCorrect == true }.count
                let rated = predictions.filter { $0.isCorrect != nil }.count
                let rate = rated > 0 ? String(format: "%.0f%%", Double(correct) / Double(rated) * 100) : "-"
                cell.textLabel?.text = "총 \(total)회  |  적중 \(correct)회"
                cell.detailTextLabel?.text = "적중률 \(rate)"

            case 2:
                if predictions.isEmpty {
                    cell.textLabel?.text = "아직 예측 기록이 없습니다"
                    cell.textLabel?.textColor = .secondaryLabel
                } else {
                    let p = predictions[indexPath.row]
                    cell.textLabel?.text = "\(p.awayTeam) vs \(p.homeTeam)"
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    cell.selectionStyle = .default
                    if let correct = p.isCorrect {
                        cell.detailTextLabel?.text = correct ? "✅ 적중" : "❌ 미적중"
                        cell.detailTextLabel?.textColor = correct ? .systemGreen : .systemRed
                    } else {
                        cell.detailTextLabel?.text = "⏳ 결과 입력"
                        cell.detailTextLabel?.textColor = .systemBlue
                    }
                }
            default: break
            }

        } else {
            switch indexPath.section {
            case 0:
                let level = LevelManager.shared.currentLevel(points: PointStore.shared.points)
                cell.textLabel?.text = "⭐️ 현재 포인트"
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
                cell.detailTextLabel?.text = "\(PointStore.shared.points)점  \(level.emoji) \(level.name)"
                cell.detailTextLabel?.font = .systemFont(ofSize: 14, weight: .bold)
                cell.detailTextLabel?.textColor = level.color

            case 1:
                if pointHistories.isEmpty {
                    cell.textLabel?.text = "포인트 내역이 없습니다"
                    cell.textLabel?.textColor = .secondaryLabel
                } else {
                    let h = pointHistories[indexPath.row]
                    let changeStr = h.change > 0 ? "+\(h.change)점" : "\(h.change)점"
                    cell.textLabel?.text = h.reason
                    cell.textLabel?.font = .systemFont(ofSize: 14)
                    cell.detailTextLabel?.text = "\(changeStr) → \(h.totalAfter)점"
                    cell.detailTextLabel?.textColor = h.change > 0 ? .systemGreen : .systemRed
                }
            default: break
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete,
              segmentControl.selectedSegmentIndex == 0,
              indexPath.section == 2,
              !predictions.isEmpty else { return }
        PredictionStore.shared.delete(predictions[indexPath.row])
        predictions.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDelegate
extension PredictionHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard segmentControl.selectedSegmentIndex == 0,
              indexPath.section == 2,
              !predictions.isEmpty else { return }
        let prediction = predictions[indexPath.row]
        guard prediction.isCorrect == nil else { return }
        showResultInput(for: prediction)
    }
}
