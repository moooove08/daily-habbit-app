import UIKit

final class CustomTabBarView: UIView {
    private let pillContainer = UIView()
    private let shapeLayer = CAShapeLayer()
    private let selectionCircle = UIView()
    private let stackView = UIStackView()
    private var tabItems: [(button: UIButton, iconView: UIImageView, label: UILabel)] = []
    private let tabHeight: CGFloat = 56
    private let horizontalInset: CGFloat = 20
    private let holeRadius: CGFloat = 26
    private let selectionRadius: CGFloat = 20
    var selectedIndex: Int = 0 {
        didSet { updateSelection(animated: true) }
    }
    var onTabSelected: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        pillContainer.translatesAutoresizingMaskIntoConstraints = false
        pillContainer.backgroundColor = .clear
        pillContainer.layer.insertSublayer(shapeLayer, at: 0)
        addSubview(pillContainer)
        pillContainer.layer.shadowColor = UIColor.black.cgColor
        pillContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        pillContainer.layer.shadowRadius = 12
        pillContainer.layer.shadowOpacity = 0.12
        pillContainer.layer.masksToBounds = false
        NSLayoutConstraint.activate([
            pillContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalInset),
            pillContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalInset),
            pillContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            pillContainer.heightAnchor.constraint(equalToConstant: tabHeight)
        ])

        selectionCircle.translatesAutoresizingMaskIntoConstraints = false
        selectionCircle.layer.cornerRadius = selectionRadius
        selectionCircle.layer.masksToBounds = true
        pillContainer.addSubview(selectionCircle)

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        pillContainer.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: pillContainer.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: pillContainer.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: pillContainer.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: pillContainer.bottomAnchor)
        ])

        let configs: [String] = ["sun.max.fill", "calendar", "chart.bar.fill"]
        for (idx, iconName) in configs.enumerated() {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            let iconView = UIImageView(image: UIImage(systemName: iconName))
            iconView.contentMode = .scaleAspectFit
            iconView.tintColor = AppTheme.current.tabBarUnselected
            iconView.translatesAutoresizingMaskIntoConstraints = false
            let label = UILabel()
            label.isHidden = true
            label.translatesAutoresizingMaskIntoConstraints = false
            let btn = UIButton(type: .system)
            btn.tag = idx
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            container.addSubview(iconView)
            container.addSubview(label)
            container.addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: 26),
                iconView.heightAnchor.constraint(equalToConstant: 26),
                btn.topAnchor.constraint(equalTo: container.topAnchor),
                btn.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                btn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                btn.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            stackView.addArrangedSubview(container)
            tabItems.append((btn, iconView, label))
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pillContainer.layoutIfNeeded()
        let rect = pillContainer.bounds
        shapeLayer.frame = rect
        shapeLayer.path = nil
        let r = tabHeight / 2
        let pillPath = UIBezierPath(roundedRect: rect, cornerRadius: r)
        let idx = max(0, min(selectedIndex, tabItems.count - 1))
        let segmentWidth = rect.width / CGFloat(tabItems.count)
        let circleCenterX = segmentWidth * CGFloat(idx) + segmentWidth / 2
        let holePath = UIBezierPath(ovalIn: CGRect(x: circleCenterX - holeRadius, y: tabHeight / 2 - holeRadius, width: holeRadius * 2, height: holeRadius * 2))
        pillPath.append(holePath)
        pillPath.usesEvenOddFillRule = true
        shapeLayer.path = pillPath.cgPath
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = AppTheme.current.tabBarBackground.cgColor
        selectionCircle.backgroundColor = AppTheme.current.tabBarSelected
        selectionCircle.frame = CGRect(x: circleCenterX - selectionRadius, y: tabHeight / 2 - selectionRadius, width: selectionRadius * 2, height: selectionRadius * 2)
        updateTabAppearance()
    }

    private func updateTabAppearance() {
        for (idx, (_, iconView, _)) in tabItems.enumerated() {
            let selected = idx == selectedIndex
            iconView.tintColor = selected ? .white : AppTheme.current.tabBarUnselected
        }
    }

    private func updateSelection(animated: Bool) {
        setNeedsLayout()
        layoutIfNeeded()
        updateTabAppearance()
    }

    @objc private func tabTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        onTabSelected?(sender.tag)
    }

    func applyTheme() {
        shapeLayer.fillColor = AppTheme.current.tabBarBackground.cgColor
        selectionCircle.backgroundColor = AppTheme.current.tabBarSelected
        updateTabAppearance()
    }
}
