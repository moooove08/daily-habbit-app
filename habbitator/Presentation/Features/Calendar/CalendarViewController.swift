import UIKit
import ObjectiveC

final class CalendarViewController: UIViewController {
    private let viewModel: CalendarViewModel
    private let titleLabel = UILabel()
    private let monthLabel = UILabel()
    private let gridView = UIView()
    private let bannerImageView = UIImageView()
    private let weekStack = UIStackView()
    private var dayCellDates: [Date] = []
    private var dayStacks: [UIStackView] = []

    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        titleLabel.text = "Calendar"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textColor = AppTheme.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        monthLabel.font = .preferredFont(forTextStyle: .title2)
        monthLabel.textColor = AppTheme.label
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(monthLabel)
        let prevBtn = UIButton(type: .system)
        prevBtn.setTitle("‹", for: .normal)
        prevBtn.titleLabel?.font = .systemFont(ofSize: 28, weight: .medium)
        prevBtn.tintColor = AppTheme.accent
        prevBtn.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)
        prevBtn.translatesAutoresizingMaskIntoConstraints = false
        let nextBtn = UIButton(type: .system)
        nextBtn.setTitle("›", for: .normal)
        nextBtn.titleLabel?.font = .systemFont(ofSize: 28, weight: .medium)
        nextBtn.tintColor = AppTheme.accent
        nextBtn.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        nextBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(prevBtn)
        view.addSubview(nextBtn)
        gridView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridView)
        let bannerImage = UIImage(named: "bannre1")
        bannerImageView.image = bannerImage
        bannerImageView.contentMode = .scaleAspectFit
        bannerImageView.clipsToBounds = true
        bannerImageView.layer.cornerRadius = 12
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerImageView)
        let aspectRatio: CGFloat
        if let img = bannerImage, img.size.width > 0 {
            aspectRatio = img.size.height / img.size.width
        } else {
            aspectRatio = 0.5
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            monthLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            monthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            prevBtn.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            prevBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextBtn.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            nextBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            gridView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 20),
            gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            gridView.bottomAnchor.constraint(lessThanOrEqualTo: bannerImageView.topAnchor, constant: -20),
            bannerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bannerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bannerImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            bannerImageView.heightAnchor.constraint(equalTo: bannerImageView.widthAnchor, multiplier: aspectRatio)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buildGrid()
    }

    private func buildGrid() {
        gridView.subviews.forEach { $0.removeFromSuperview() }
        dayStacks.removeAll()
        dayCellDates.removeAll()
        let month = viewModel.loadMonth()
        monthLabel.text = month.title
        let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
        let rowStack = UIStackView()
        rowStack.axis = .vertical
        rowStack.spacing = 8
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        gridView.addSubview(rowStack)
        let headerRow = UIStackView()
        headerRow.axis = .horizontal
        headerRow.distribution = .fillEqually
        for s in dayLabels {
            let l = UILabel()
            l.text = s
            l.font = .systemFont(ofSize: 12)
            l.textColor = AppTheme.secondaryLabel
            l.textAlignment = .center
            headerRow.addArrangedSubview(l)
        }
        rowStack.addArrangedSubview(headerRow)
        var day = 1
        var row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 4
        for _ in 0..<month.leadingEmptyDays {
            row.addArrangedSubview(UIView())
        }
        for item in month.days {
            let cell = dayCell(item: item) { [weak self] tappedDate in
                self?.showDayDetail(for: tappedDate)
            }
            row.addArrangedSubview(cell.view)
            dayStacks.append(cell.stack)
            dayCellDates.append(item.date)
            if (month.leadingEmptyDays + day) % 7 == 0 {
                rowStack.addArrangedSubview(row)
                row = UIStackView()
                row.axis = .horizontal
                row.distribution = .fillEqually
                row.spacing = 4
            }
            day += 1
        }
        if row.arrangedSubviews.count > 0 {
            while row.arrangedSubviews.count < 7 {
                row.addArrangedSubview(UIView())
            }
            rowStack.addArrangedSubview(row)
        }
        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: gridView.topAnchor),
            rowStack.leadingAnchor.constraint(equalTo: gridView.leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: gridView.trailingAnchor),
            rowStack.bottomAnchor.constraint(equalTo: gridView.bottomAnchor)
        ])
        for (idx, stack) in dayStacks.enumerated() {
            guard idx < dayCellDates.count else { continue }
            let completed = month.days[idx].completedCount
            for (i, dot) in stack.arrangedSubviews.enumerated() {
                dot.isHidden = i >= completed
            }
        }
    }

    private func dayCell(item: CalendarDayItem, onTap: @escaping (Date) -> Void) -> (view: UIView, stack: UIStackView) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        for _ in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = AppTheme.accent
            dot.layer.cornerRadius = 3
            dot.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(dot)
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 6),
                dot.heightAnchor.constraint(equalToConstant: 6)
            ])
        }
        let label = UILabel()
        label.text = "\(item.dayNumber)"
        label.font = .systemFont(ofSize: 14)
        label.textColor = AppTheme.label
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            container.heightAnchor.constraint(equalToConstant: 44)
        ])
        let tap = UITapGestureRecognizer(target: self, action: nil)
        tap.cancelsTouchesInView = false
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(tap)
        let wrapper = CalendarDayTapWrapper(date: item.date, action: onTap)
        objc_setAssociatedObject(container, &CalendarViewController.tapKey, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        tap.addTarget(self, action: #selector(dayTapped(_:)))
        return (container, stack)
    }

    private static var tapKey: UInt8 = 0

    @objc private func dayTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view,
              let wrapper = objc_getAssociatedObject(view, &CalendarViewController.tapKey) as? CalendarDayTapWrapper else { return }
        wrapper.action(wrapper.date)
    }

    private func showDayDetail(for date: Date) {
        let vc = DayDetailViewController(viewModel: viewModel.makeDayDetailViewModel(for: date))
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }

    @objc private func prevMonth() {
        viewModel.showPreviousMonth()
        buildGrid()
    }

    @objc private func nextMonth() {
        viewModel.showNextMonth()
        buildGrid()
    }

    func applyTheme() {
        view.backgroundColor = AppTheme.background
        view.tintColor = AppTheme.accent
        titleLabel.textColor = AppTheme.label
        monthLabel.textColor = AppTheme.label
        for subview in view.subviews {
            (subview as? UIButton)?.tintColor = AppTheme.accent
        }
        buildGrid()
    }
}

private final class CalendarDayTapWrapper {
    let date: Date
    let action: (Date) -> Void
    init(date: Date, action: @escaping (Date) -> Void) {
        self.date = date
        self.action = action
    }
}
