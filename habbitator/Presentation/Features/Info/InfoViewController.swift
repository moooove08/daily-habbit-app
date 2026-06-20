import UIKit

final class InfoViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let bannerImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .appThemeDidChange, object: nil)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        titleLabel.text = "App Information"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textColor = AppTheme.label
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(titleLabel)

        bodyLabel.text = """
        This app helps you stay in shape and build better habits.

        By focusing on just 3 habits a day, you keep yourself accountable without overwhelm. Small, consistent actions add up: drinking water, moving a little, reading, or resting well.

        Use it to build qualities like discipline, consistency, and self-care. Track your progress, keep your streak, and celebrate full days when all three habits are done.
        """
        bodyLabel.font = .preferredFont(forTextStyle: .body)
        bodyLabel.textColor = AppTheme.secondaryLabel
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(bodyLabel)

        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        closeButton.tintColor = AppTheme.accent
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        let nhImage = UIImage(named: "nh")
        bannerImageView.image = nhImage
        bannerImageView.contentMode = .scaleAspectFit
        bannerImageView.clipsToBounds = true
        bannerImageView.layer.cornerRadius = 12
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerImageView)

        let nhAspect: CGFloat
        if let img = nhImage, img.size.width > 0 {
            nhAspect = img.size.height / img.size.width
        } else {
            nhAspect = 0.5
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            bodyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bodyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            bodyLabel.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            closeButton.bottomAnchor.constraint(equalTo: bannerImageView.topAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalToConstant: 50),
            bannerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bannerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bannerImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70),
            bannerImageView.heightAnchor.constraint(equalTo: bannerImageView.widthAnchor, multiplier: nhAspect)
        ])
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func themeDidChange() {
        applyTheme()
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    func applyTheme() {
        view.backgroundColor = AppTheme.background
        titleLabel.textColor = AppTheme.label
        bodyLabel.textColor = AppTheme.secondaryLabel
        closeButton.tintColor = AppTheme.accent
    }
}
