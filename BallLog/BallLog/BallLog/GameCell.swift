import UIKit

class GameCell: UITableViewCell {

    private let awayLogoView = UIImageView()
    private let homeLogoView = UIImageView()
    private let awayLabel = UILabel()
    private let homeLabel = UILabel()
    private let awayScoreLabel = UILabel()
    private let homeScoreLabel = UILabel()
    private let statusLabel = UILabel()

    // 이미지 캐시
    private static var imageCache = NSCache<NSString, UIImage>()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [awayLogoView, homeLogoView, awayLabel, homeLabel,
         awayScoreLabel, homeScoreLabel, statusLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        [awayLogoView, homeLogoView].forEach {
            $0.contentMode = .scaleAspectFit
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 14
            $0.clipsToBounds = true
        }

        awayLabel.font = .systemFont(ofSize: 13, weight: .medium)
        awayLabel.numberOfLines = 1
        awayLabel.adjustsFontSizeToFitWidth = true
        awayLabel.minimumScaleFactor = 0.7

        homeLabel.font = .systemFont(ofSize: 13, weight: .medium)
        homeLabel.numberOfLines = 1
        homeLabel.adjustsFontSizeToFitWidth = true
        homeLabel.minimumScaleFactor = 0.7

        awayScoreLabel.font = .systemFont(ofSize: 14, weight: .bold)
        awayScoreLabel.textAlignment = .right
        homeScoreLabel.font = .systemFont(ofSize: 14, weight: .bold)
        homeScoreLabel.textAlignment = .right

        statusLabel.font = .systemFont(ofSize: 11)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 2

        NSLayoutConstraint.activate([
            awayLogoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            awayLogoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            awayLogoView.widthAnchor.constraint(equalToConstant: 28),
            awayLogoView.heightAnchor.constraint(equalToConstant: 28),

            homeLogoView.topAnchor.constraint(equalTo: awayLogoView.bottomAnchor, constant: 6),
            homeLogoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            homeLogoView.widthAnchor.constraint(equalToConstant: 28),
            homeLogoView.heightAnchor.constraint(equalToConstant: 28),

            awayLabel.centerYAnchor.constraint(equalTo: awayLogoView.centerYAnchor),
            awayLabel.leadingAnchor.constraint(equalTo: awayLogoView.trailingAnchor, constant: 8),
            awayLabel.trailingAnchor.constraint(equalTo: awayScoreLabel.leadingAnchor, constant: -8),

            homeLabel.centerYAnchor.constraint(equalTo: homeLogoView.centerYAnchor),
            homeLabel.leadingAnchor.constraint(equalTo: homeLogoView.trailingAnchor, constant: 8),
            homeLabel.trailingAnchor.constraint(equalTo: homeScoreLabel.leadingAnchor, constant: -8),

            awayScoreLabel.centerYAnchor.constraint(equalTo: awayLogoView.centerYAnchor),
            awayScoreLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -12),
            awayScoreLabel.widthAnchor.constraint(equalToConstant: 24),

            homeScoreLabel.centerYAnchor.constraint(equalTo: homeLogoView.centerYAnchor),
            homeScoreLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -12),
            homeScoreLabel.widthAnchor.constraint(equalToConstant: 24),

            statusLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusLabel.widthAnchor.constraint(equalToConstant: 50),

            contentView.bottomAnchor.constraint(equalTo: homeLogoView.bottomAnchor, constant: 12),
        ])
    }

    func configure(with game: MLBGame) {
        awayLabel.text = game.teams.away.team.name
        homeLabel.text = game.teams.home.team.name
        awayScoreLabel.text = game.teams.away.score.map { "\($0)" } ?? "-"
        homeScoreLabel.text = game.teams.home.score.map { "\($0)" } ?? "-"

        loadLogo(teamId: game.teams.away.team.id, into: awayLogoView)
        loadLogo(teamId: game.teams.home.team.id, into: homeLogoView)

        switch game.status.detailedState {
        case "Scheduled":   statusLabel.text = "예정";   statusLabel.textColor = .systemBlue
        case "In Progress": statusLabel.text = "진행중"; statusLabel.textColor = .systemGreen
        case "Final":       statusLabel.text = "종료";   statusLabel.textColor = .secondaryLabel
        case "Postponed":   statusLabel.text = "연기";   statusLabel.textColor = .systemOrange
        default:
            statusLabel.text = game.status.detailedState
            statusLabel.textColor = .secondaryLabel
        }
    }

    private func loadLogo(teamId: Int, into imageView: UIImageView) {
        // PNG 형식으로 변경
        let urlString = "https://www.mlbstatic.com/team-logos/\(teamId).png"
        let cacheKey = NSString(string: urlString)

        // 캐시에 있으면 바로 사용
        if let cached = GameCell.imageCache.object(forKey: cacheKey) {
            imageView.image = cached
            return
        }

        // 기본 이미지 먼저 설정
        imageView.image = UIImage(systemName: "baseball.fill")
        imageView.tintColor = .systemGray3

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let image = UIImage(data: data) else { return }

            // 캐시 저장
            GameCell.imageCache.setObject(image, forKey: cacheKey)

            DispatchQueue.main.async {
                imageView.image = image
                imageView.backgroundColor = .clear
            }
        }.resume()
    }
}
