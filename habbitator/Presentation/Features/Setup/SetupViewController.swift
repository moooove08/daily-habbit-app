import UIKit

final class SetupViewController: UIViewController {
    private let viewModel: SetupViewModel
    private let onComplete: () -> Void
    private let onCancel: (() -> Void)?
    private let titleLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let field1 = UITextField()
    private let field2 = UITextField()
    private let field3 = UITextField()
    private let bannerImageView = UIImageView()
    private let randomButton = UIButton(type: .system)
    private let continueButton = UIButton(type: .system)

    init(viewModel: SetupViewModel, onComplete: @escaping () -> Void, onCancel: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onComplete = onComplete
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        titleLabel.text = "Name your 3 habits"
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.textColor = AppTheme.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        cancelButton.tintColor = AppTheme.accent
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        cancelButton.isHidden = true

        for f in [field1, field2, field3] {
            f.placeholder = "Habit name"
            f.borderStyle = .roundedRect
            f.autocapitalizationType = .sentences
            f.returnKeyType = .done
            f.delegate = self
            f.addTarget(self, action: #selector(fieldsEditingChanged), for: .editingChanged)
            f.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(f)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        let newhabbImage = UIImage(named: "newhabb")
        bannerImageView.image = newhabbImage
        bannerImageView.contentMode = .scaleAspectFit
        bannerImageView.clipsToBounds = true
        bannerImageView.layer.cornerRadius = 12
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerImageView)

        randomButton.setImage(UIImage(systemName: "shuffle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)), for: .normal)
        randomButton.tintColor = AppTheme.accent
        randomButton.backgroundColor = AppTheme.secondaryBackground
        randomButton.layer.cornerRadius = 12
        randomButton.addTarget(self, action: #selector(randomTapped), for: .touchUpInside)
        randomButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(randomButton)

        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        continueButton.backgroundColor = AppTheme.accent
        continueButton.layer.cornerRadius = 12
        continueButton.isEnabled = false
        continueButton.alpha = 0.6
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(continueButton)

        let newhabbAspect: CGFloat
        if let img = newhabbImage, img.size.width > 0 {
            newhabbAspect = img.size.height / img.size.width
        } else {
            newhabbAspect = 0.5
        }
        if viewModel.isReplacing, onCancel != nil {
            cancelButton.isHidden = false
        }
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            cancelButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            field1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            field1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            field1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            field1.heightAnchor.constraint(equalToConstant: 44),
            field2.topAnchor.constraint(equalTo: field1.bottomAnchor, constant: 16),
            field2.leadingAnchor.constraint(equalTo: field1.leadingAnchor),
            field2.trailingAnchor.constraint(equalTo: field1.trailingAnchor),
            field2.heightAnchor.constraint(equalToConstant: 44),
            field3.topAnchor.constraint(equalTo: field2.bottomAnchor, constant: 16),
            field3.leadingAnchor.constraint(equalTo: field1.leadingAnchor),
            field3.trailingAnchor.constraint(equalTo: field1.trailingAnchor),
            field3.heightAnchor.constraint(equalToConstant: 44),
            randomButton.topAnchor.constraint(equalTo: field3.bottomAnchor, constant: 24),
            randomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            randomButton.widthAnchor.constraint(equalToConstant: 50),
            randomButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.topAnchor.constraint(equalTo: randomButton.topAnchor),
            continueButton.leadingAnchor.constraint(equalTo: randomButton.trailingAnchor, constant: 12),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            bannerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bannerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bannerImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            bannerImageView.heightAnchor.constraint(equalTo: bannerImageView.widthAnchor, multiplier: newhabbAspect),
            continueButton.bottomAnchor.constraint(lessThanOrEqualTo: bannerImageView.topAnchor, constant: -16)
        ])
    }

    @objc private func cancelTapped() {
        onCancel?()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func fieldsEditingChanged() {
        let filled = viewModel.canContinue(with: enteredTitles)
        continueButton.isEnabled = filled
        continueButton.alpha = filled ? 1 : 0.6
    }

    private var enteredTitles: [String] {
        [field1.text ?? "", field2.text ?? "", field3.text ?? ""]
    }

    @objc private func randomTapped() {
        let picked = viewModel.randomTitles()
        field1.text = picked.count > 0 ? picked[0] : ""
        field2.text = picked.count > 1 ? picked[1] : ""
        field3.text = picked.count > 2 ? picked[2] : ""
        fieldsEditingChanged()
    }

    @objc private func continueTapped() {
        viewModel.save(titles: enteredTitles)
        let phrase = viewModel.motivatingPhrase()
        let popup = ThemedPopupViewController(message: phrase, buttonTitle: "Let's go!") { [onComplete] in
            onComplete()
        }
        present(popup, animated: true)
    }

    func applyTheme() {
        view.backgroundColor = AppTheme.background
        titleLabel.textColor = AppTheme.label
        cancelButton.tintColor = AppTheme.accent
        randomButton.tintColor = AppTheme.accent
        randomButton.backgroundColor = AppTheme.secondaryBackground
        continueButton.backgroundColor = AppTheme.accent
        continueButton.alpha = continueButton.isEnabled ? 1 : 0.6
    }
}

extension SetupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
