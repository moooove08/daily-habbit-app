import UIKit

final class NewDayChoiceViewController: UIViewController {
    private let onKeep: () -> Void
    private let onChange: () -> Void

    init(onKeep: @escaping () -> Void, onChange: @escaping () -> Void) {
        self.onKeep = onKeep
        self.onChange = onChange
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        let label = UILabel()
        label.text = "New day! Keep your current 3 habits or choose new ones?"
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = AppTheme.label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        let keepBtn = UIButton(type: .system)
        keepBtn.setTitle("Keep same", for: .normal)
        keepBtn.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        keepBtn.tintColor = AppTheme.accent
        keepBtn.addTarget(self, action: #selector(keepTapped), for: .touchUpInside)
        keepBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keepBtn)
        let changeBtn = UIButton(type: .system)
        changeBtn.setTitle("Change habits", for: .normal)
        changeBtn.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        changeBtn.tintColor = AppTheme.accent
        changeBtn.addTarget(self, action: #selector(changeTapped), for: .touchUpInside)
        changeBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(changeBtn)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            keepBtn.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 32),
            keepBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeBtn.topAnchor.constraint(equalTo: keepBtn.bottomAnchor, constant: 16),
            changeBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func keepTapped() {
        onKeep()
    }

    @objc private func changeTapped() {
        onChange()
    }

    func applyTheme() {
        view.backgroundColor = AppTheme.background
    }
}
