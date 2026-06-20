import UIKit

final class TodayViewController: UIViewController {
    private let viewModel: TodayViewModel
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let headerStack = UIStackView()
    private let titleLabel = UILabel()
    private let infoButton = UIButton(type: .system)
    private let dateLabel = UILabel()
    private let stackView = UIStackView()
    private let bannerImageView = UIImageView()
    private var habitCards: [(item: TodayHabitItem, button: UIButton, card: UIView)] = []

    init(viewModel: TodayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.distribution = .equalSpacing
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Today"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textColor = AppTheme.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoButton.setImage(UIImage(systemName: "info.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)), for: .normal)
        infoButton.tintColor = AppTheme.accent
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(infoButton)
        contentStack.addArrangedSubview(headerStack)
        dateLabel.font = .preferredFont(forTextStyle: .title3)
        dateLabel.textColor = AppTheme.secondaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(dateLabel)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(stackView)
        let habbImage = UIImage(named: "habb")
        bannerImageView.image = habbImage
        bannerImageView.contentMode = .scaleAspectFit
        bannerImageView.clipsToBounds = true
        bannerImageView.layer.cornerRadius = 12
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerImageView)
        let habbAspect: CGFloat
        if let img = habbImage, img.size.width > 0 {
            habbAspect = img.size.height / img.size.width
        } else {
            habbAspect = 0.5
        }
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bannerImageView.topAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            bannerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bannerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bannerImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            bannerImageView.heightAnchor.constraint(equalTo: bannerImageView.widthAnchor, multiplier: habbAspect)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dateLabel.text = viewModel.dateText
        reloadCards()
    }

    private func reloadCards() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        habitCards.removeAll()
        for item in viewModel.loadItems() {
            let card = UIView()
            card.layer.cornerRadius = 12
            card.translatesAutoresizingMaskIntoConstraints = false
            let titleLabel = UILabel()
            titleLabel.text = item.title
            titleLabel.font = .preferredFont(forTextStyle: .headline)
            titleLabel.textColor = AppTheme.label
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            let btn = UIButton(type: .system)
            btn.tag = habitCards.count
            btn.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
            let completed = item.isCompleted
            btn.setImage(completed ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
            btn.tintColor = completed ? AppTheme.secondaryLabel : AppTheme.accent
            btn.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(titleLabel)
            card.addSubview(btn)
            if completed {
                card.backgroundColor = AppTheme.completedMuted
            } else {
                card.backgroundColor = AppTheme.secondaryBackground
            }
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                btn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                btn.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                btn.widthAnchor.constraint(equalToConstant: 44),
                btn.heightAnchor.constraint(equalToConstant: 44)
            ])
            card.heightAnchor.constraint(equalToConstant: 64).isActive = true
            stackView.addArrangedSubview(card)
            habitCards.append((item, btn, card))
        }
    }

    @objc private func checkboxTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx < habitCards.count else { return }
        let card = habitCards[idx]
        guard let result = viewModel.toggleHabit(id: card.item.id) else { return }
        let completed = result.item.isCompleted
        habitCards[idx].item = result.item
        sender.setImage(completed ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
        sender.tintColor = completed ? AppTheme.secondaryLabel : AppTheme.accent
        card.card.backgroundColor = completed ? AppTheme.completedMuted : AppTheme.secondaryBackground
        if result.isFullDay {
            showPraisePopup()
        }
    }

    private func showPraisePopup() {
        let phrase = viewModel.praisePhrase()
        let popup = ThemedPopupViewController(message: phrase, buttonTitle: "Thanks!")
        present(popup, animated: true)
    }

    @objc private func infoTapped() {
        let info = InfoViewController()
        info.modalPresentationStyle = .pageSheet
        present(info, animated: true)
    }

    func applyTheme() {
        view.backgroundColor = AppTheme.background
        titleLabel.textColor = AppTheme.label
        infoButton.tintColor = AppTheme.accent
        dateLabel.textColor = AppTheme.secondaryLabel
        reloadCards()
    }
}
