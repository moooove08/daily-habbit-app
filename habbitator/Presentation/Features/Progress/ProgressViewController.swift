import UIKit

final class ProgressViewController: UIViewController {
    private let viewModel: ProgressViewModel
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let themeButton = UIButton(type: .system)

    init(viewModel: ProgressViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        titleLabel.text = "Progress"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textColor = AppTheme.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
        themeButton.setImage(UIImage(systemName: "paintpalette.fill", withConfiguration: config), for: .normal)
        themeButton.tintColor = AppTheme.accent
        themeButton.addTarget(self, action: #selector(themeTapped), for: .touchUpInside)
        themeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(themeButton)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: themeButton.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: themeButton.leadingAnchor, constant: -12),
            themeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            themeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            themeButton.widthAnchor.constraint(equalToConstant: 88),
            themeButton.heightAnchor.constraint(equalToConstant: 88),
            scrollView.topAnchor.constraint(equalTo: themeButton.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    @objc private func themeTapped() {
        let all = AppThemeKind.allCases
        guard let idx = all.firstIndex(of: AppTheme.currentKind) else { return }
        let nextIdx = (idx + 1) % all.count
        AppTheme.currentKind = all[nextIdx]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        themeButton.tintColor = AppTheme.accent
        reload()
    }

    private func reload() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let data = viewModel.load()

        let statsSection = section(title: "Statistics", views: [
            row(label: "Total habits completed", value: "\(data.totalCompletedHabits)"),
            row(label: "Days with all 3 habits done", value: "\(data.totalFullDays)")
        ])
        contentStack.addArrangedSubview(statsSection)

        let streakSection = section(title: "Streaks (all 3 habits)", views: [
            row(label: "Current streak", value: "\(data.currentFullStreak) days"),
            row(label: "Best streak", value: "\(data.bestFullStreak) days")
        ])
        contentStack.addArrangedSubview(streakSection)

        let weekView = weekRowView(dates: data.weekDates, filled: data.weekFilled)
        contentStack.addArrangedSubview(section(title: "This week", subtitle: "Filled = all 3 habits done that day", views: [weekView]))

        let monthView = monthGridView(dates: data.monthDates, filled: data.monthFilled)
        contentStack.addArrangedSubview(section(title: "This month", subtitle: "Filled = all 3 habits done that day", views: [monthView]))
    }

    private static let shortWeekday: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()

    private func weekRowView(dates: [Date], filled: [Bool]) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        let size: CGFloat = 40
        for (i, date) in dates.enumerated() {
            let cell = dayCellView(
                title: Self.shortWeekday.string(from: date),
                filled: filled[i],
                size: size
            )
            stack.addArrangedSubview(cell)
        }
        return stack
    }

    private func monthGridView(dates: [Date], filled: [Bool]) -> UIView {
        let cal = Calendar.current
        let first = dates.first ?? Date()
        let weekdayOfFirst = cal.component(.weekday, from: first)
        let firstWeekday = cal.firstWeekday
        var offset = weekdayOfFirst - firstWeekday
        if offset < 0 { offset += 7 }
        let columns = 7
        let rowStack = UIStackView()
        rowStack.axis = .vertical
        rowStack.spacing = 6
        let cellSize: CGFloat = 32
        var row = UIStackView()
        row.axis = .horizontal
        row.spacing = 6
        row.distribution = .fillEqually
        for _ in 0..<offset {
            row.addArrangedSubview(dayCellView(title: "", filled: false, size: cellSize))
        }
        for (i, date) in dates.enumerated() {
            if row.arrangedSubviews.count >= columns {
                rowStack.addArrangedSubview(row)
                row = UIStackView()
                row.axis = .horizontal
                row.spacing = 6
                row.distribution = .fillEqually
            }
            let dayNum = cal.component(.day, from: date)
            let cell = dayCellView(title: "\(dayNum)", filled: filled[i], size: cellSize)
            row.addArrangedSubview(cell)
        }
        if !row.arrangedSubviews.isEmpty {
            while row.arrangedSubviews.count < columns {
                row.addArrangedSubview(dayCellView(title: "", filled: false, size: cellSize))
            }
            rowStack.addArrangedSubview(row)
        }
        return rowStack
    }

    private func dayCellView(title: String, filled: Bool, size: CGFloat) -> UIView {
        let wrap = UIStackView()
        wrap.axis = .vertical
        wrap.alignment = .center
        wrap.spacing = 4
        let box = UIView()
        box.backgroundColor = filled ? AppTheme.accent : AppTheme.completedMuted
        box.layer.cornerRadius = 6
        box.translatesAutoresizingMaskIntoConstraints = false
        box.widthAnchor.constraint(equalToConstant: size).isActive = true
        box.heightAnchor.constraint(equalToConstant: size).isActive = true
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = AppTheme.secondaryLabel
        wrap.addArrangedSubview(box)
        wrap.addArrangedSubview(label)
        return wrap
    }

    private func section(title: String, subtitle: String? = nil, views: [UIView]) -> UIView {
        let wrap = UIStackView()
        wrap.axis = .vertical
        wrap.spacing = 12
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = AppTheme.label
        wrap.addArrangedSubview(label)
        if let sub = subtitle, !sub.isEmpty {
            let subLabel = UILabel()
            subLabel.text = sub
            subLabel.font = .preferredFont(forTextStyle: .caption1)
            subLabel.textColor = AppTheme.secondaryLabel
            wrap.addArrangedSubview(subLabel)
        }
        for v in views {
            wrap.addArrangedSubview(v)
        }
        return wrap
    }

    private func row(label: String, value: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .equalSpacing
        let l = UILabel()
        l.text = label
        l.font = .preferredFont(forTextStyle: .body)
        l.textColor = AppTheme.label
        let r = UILabel()
        r.text = value
        r.font = .preferredFont(forTextStyle: .body)
        r.textColor = AppTheme.secondaryLabel
        row.addArrangedSubview(l)
        row.addArrangedSubview(r)
        return row
    }

    private func barView(counts: [Int], maxVal: Int) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillEqually
        let height: CGFloat = 24
        for c in counts.reversed() {
            let bar = UIView()
            bar.backgroundColor = c > 0 ? AppTheme.accent : AppTheme.completedMuted
            bar.layer.cornerRadius = 4
            bar.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(bar)
            bar.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        return stack
    }

    func applyTheme() {
        view.backgroundColor = AppTheme.background
        titleLabel.textColor = AppTheme.label
        themeButton.tintColor = AppTheme.accent
        reload()
    }
}
