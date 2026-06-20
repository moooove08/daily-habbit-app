import UIKit

/// Full-screen overlay with a themed, square-styled popup card.
final class ThemedPopupViewController: UIViewController {
    private let message: String
    private let buttonTitle: String
    private let onDismiss: (() -> Void)?
    private weak var cardView: UIView?

    init(message: String, buttonTitle: String, onDismiss: (() -> Void)? = nil) {
        self.message = message
        self.buttonTitle = buttonTitle
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        let card = UIView()
        card.backgroundColor = AppTheme.secondaryBackground
        card.layer.cornerRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = message
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = AppTheme.label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(type: .system)
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.tintColor = AppTheme.accent
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(label)
        card.addSubview(button)
        view.addSubview(card)
        cardView = card

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            card.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 320),
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            button.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }

    @objc private func buttonTapped() {
        dismiss(animated: true) { [onDismiss] in
            onDismiss?()
        }
    }

    @objc private func overlayTapped(_ gesture: UITapGestureRecognizer) {
        let loc = gesture.location(in: view)
        guard let card = cardView, !card.frame.contains(loc) else { return }
        dismiss(animated: true) { [onDismiss] in onDismiss?() }
    }
}
