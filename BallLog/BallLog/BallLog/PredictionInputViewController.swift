import UIKit

class PredictionInputViewController: UIViewController {

    // MARK: - 프로퍼티
    private let game: MLBGame
    private var selectedTeam: String = ""

    // MARK: - UI
    private let matchupLabel = UILabel()
    private let guideLabel = UILabel()
    private let awayButton = UIButton(type: .system)
    private let homeButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    // MARK: - 초기화
    init(game: MLBGame) {
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI 설정
    private func setupUI() {
        title = "예측 입력"
        view.backgroundColor = .systemBackground

        // 매치업 레이블
        matchupLabel.text = "\(game.teams.away.team.name)  VS  \(game.teams.home.team.name)"
        matchupLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        matchupLabel.textAlignment = .center

        // 안내 레이블
        guideLabel.text = "승리 팀을 예측하세요"
        guideLabel.font = .systemFont(ofSize: 14)
        guideLabel.textColor = .secondaryLabel
        guideLabel.textAlignment = .center

        // 어웨이 버튼
        awayButton.setTitle(game.teams.away.team.name, for: .normal)
        awayButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        awayButton.backgroundColor = .systemGray5
        awayButton.setTitleColor(.label, for: .normal)
        awayButton.layer.cornerRadius = 10
        awayButton.addTarget(self, action: #selector(awayTapped), for: .touchUpInside)

        // 홈 버튼
        homeButton.setTitle(game.teams.home.team.name, for: .normal)
        homeButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        homeButton.backgroundColor = .systemGray5
        homeButton.setTitleColor(.label, for: .normal)
        homeButton.layer.cornerRadius = 10
        homeButton.addTarget(self, action: #selector(homeTapped), for: .touchUpInside)

        // 저장 버튼
        saveButton.setTitle("예측 저장", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        saveButton.backgroundColor = .systemGray3
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.isEnabled = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        [matchupLabel, guideLabel, awayButton, homeButton, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            matchupLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            matchupLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            matchupLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            guideLabel.topAnchor.constraint(equalTo: matchupLabel.bottomAnchor, constant: 12),
            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            awayButton.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 30),
            awayButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            awayButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.43),
            awayButton.heightAnchor.constraint(equalToConstant: 50),

            homeButton.centerYAnchor.constraint(equalTo: awayButton.centerYAnchor),
            homeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            homeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.43),
            homeButton.heightAnchor.constraint(equalToConstant: 50),

            saveButton.topAnchor.constraint(equalTo: awayButton.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

    // MARK: - 액션
    @objc private func awayTapped() {
        selectedTeam = game.teams.away.team.name
        updateButtonStyle()
    }

    @objc private func homeTapped() {
        selectedTeam = game.teams.home.team.name
        updateButtonStyle()
    }

    private func updateButtonStyle() {
        let isAway = selectedTeam == game.teams.away.team.name

        awayButton.backgroundColor = isAway ? .systemBlue : .systemGray5
        awayButton.setTitleColor(isAway ? .white : .label, for: .normal)
        homeButton.backgroundColor = isAway ? .systemGray5 : .systemBlue
        homeButton.setTitleColor(isAway ? .label : .white, for: .normal)

        saveButton.isEnabled = true
        saveButton.backgroundColor = .systemBlue
    }

    @objc private func saveTapped() {
        let prediction = Prediction(
            id: UUID(),
            gamePk: game.gamePk,
            gameDate: game.gameDate,
            homeTeam: game.teams.home.team.name,
            awayTeam: game.teams.away.team.name,
            predictedTeam: selectedTeam,
            actualWinner: nil,
            isCorrect: nil
        )
        PredictionStore.shared.save(prediction)

        let alert = UIAlertController(title: "저장 완료", message: "예측이 저장되었습니다!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
