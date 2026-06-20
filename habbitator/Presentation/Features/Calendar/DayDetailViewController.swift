import UIKit

final class DayDetailViewController: UIViewController {
    private let viewModel: DayDetailViewModel
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    init(viewModel: DayDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        let closeBtn = UIButton(type: .system)
        closeBtn.setTitle("Close", for: .normal)
        closeBtn.tintColor = AppTheme.accent
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeBtn)
        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        let dateLabel = UILabel()
        dateLabel.text = viewModel.dateText
        dateLabel.font = .preferredFont(forTextStyle: .title2)
        dateLabel.textColor = AppTheme.label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateLabel)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeBtn.leadingAnchor, constant: -12),
            scrollView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        reload()
    }

    private func reload() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let items = viewModel.loadItems()
        if items.isEmpty {
            let empty = UILabel()
            empty.text = "No habits recorded for this day"
            empty.font = .preferredFont(forTextStyle: .body)
            empty.textColor = AppTheme.secondaryLabel
            contentStack.addArrangedSubview(empty)
        } else {
            for item in items {
                let row = makeRow(title: item.title, completed: item.isCompleted)
                contentStack.addArrangedSubview(row)
            }
        }
    }

    private func makeRow(title: String, completed: Bool) -> UIView {
        let row = UIView()
        row.backgroundColor = AppTheme.secondaryBackground
        row.layer.cornerRadius = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = AppTheme.label
        label.translatesAutoresizingMaskIntoConstraints = false
        let icon = UIImageView(image: UIImage(systemName: completed ? "checkmark.circle.fill" : "circle"))
        icon.tintColor = completed ? AppTheme.accent : AppTheme.secondaryLabel
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)
        row.addSubview(icon)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            icon.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            icon.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),
            row.heightAnchor.constraint(equalToConstant: 52)
        ])
        return row
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
