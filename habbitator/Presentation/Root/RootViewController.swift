import UIKit

enum AppTab {
    case today
    case calendar
    case progress
}

final class RootViewController: UIViewController {
    private let viewModel: RootViewModel
    private var currentTab: AppTab = .today
    private let containerView = UIView()
    private let customTabBar = CustomTabBarView()
    private var setupVC: SetupViewController?
    private var newDayChoiceVC: NewDayChoiceViewController?
    private var todayVC: TodayViewController?
    private var calendarVC: CalendarViewController?
    private var progressVC: ProgressViewController?
    private let tabBarHeight: CGFloat = 56

    init(viewModel: RootViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        setupTabBar()
        setupContainer()
        if viewModel.hasHabits {
            showMainContent()
        } else {
            showSetup()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .appThemeDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func themeDidChange() {
        view.backgroundColor = AppTheme.background
        customTabBar.applyTheme()
        customTabBar.setNeedsLayout()
        customTabBar.layoutIfNeeded()
        todayVC?.applyTheme()
        calendarVC?.applyTheme()
        progressVC?.applyTheme()
        setupVC?.applyTheme()
        newDayChoiceVC?.applyTheme()
    }

    private func setupTabBar() {
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        customTabBar.onTabSelected = { [weak self] idx in
            let tab: AppTab = idx == 0 ? .today : (idx == 1 ? .calendar : .progress)
            self?.switchToTab(tab)
        }
        view.addSubview(customTabBar)
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: tabBarHeight)
        ])
    }

    private func setupContainer() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: customTabBar.topAnchor)
        ])
    }

    private func showSetup() {
        customTabBar.isHidden = true
        setupVC?.view.removeFromSuperview()
        setupVC?.removeFromParent()
        let setup = SetupViewController(viewModel: viewModel.makeSetupViewModel(isReplacing: false)) { [weak self] in
            self?.setupComplete()
        }
        setupVC = setup
        addChild(setup)
        containerView.addSubview(setup.view)
        setup.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            setup.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            setup.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            setup.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            setup.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        setup.didMove(toParent: self)
    }

    private func setupComplete() {
        customTabBar.isHidden = false
        viewModel.markHabitsChosenToday()
        setupVC?.view.removeFromSuperview()
        setupVC?.removeFromParent()
        setupVC = nil
        showMainContent()
        switchToTab(.today)
    }

    private func showNewDayChoice() {
        let choice = NewDayChoiceViewController(
            onKeep: { [weak self] in self?.didChooseKeepHabits() },
            onChange: { [weak self] in self?.didChooseChangeHabits() }
        )
        newDayChoiceVC = choice
        addChild(choice)
        containerView.addSubview(choice.view)
        choice.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            choice.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            choice.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            choice.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            choice.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        choice.didMove(toParent: self)
    }

    private func didChooseKeepHabits() {
        viewModel.keepCurrentHabits()
        newDayChoiceVC?.view.removeFromSuperview()
        newDayChoiceVC?.removeFromParent()
        newDayChoiceVC = nil
        showTodayTabContent()
    }

    private func didChooseChangeHabits() {
        newDayChoiceVC?.view.removeFromSuperview()
        newDayChoiceVC?.removeFromParent()
        newDayChoiceVC = nil
        customTabBar.isHidden = true
        showReplaceSetup()
    }

    private func showReplaceSetup() {
        setupVC?.view.removeFromSuperview()
        setupVC?.removeFromParent()
        let setup = SetupViewController(viewModel: viewModel.makeSetupViewModel(isReplacing: true), onComplete: { [weak self] in
            self?.replaceSetupComplete()
        }, onCancel: { [weak self] in
            self?.cancelReplaceHabits()
        })
        setupVC = setup
        addChild(setup)
        containerView.addSubview(setup.view)
        setup.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            setup.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            setup.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            setup.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            setup.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        setup.didMove(toParent: self)
    }

    private func replaceSetupComplete() {
        guard let setup = setupVC else { return }
        func finish() {
            viewModel.markHabitsChosenToday()
            setupVC?.view.removeFromSuperview()
            setupVC?.removeFromParent()
            setupVC = nil
            customTabBar.isHidden = false
            showTodayTabContent()
        }
        if setup.presentedViewController != nil {
            setup.dismiss(animated: true, completion: finish)
        } else {
            finish()
        }
    }

    private func cancelReplaceHabits() {
        setupVC?.view.removeFromSuperview()
        setupVC?.removeFromParent()
        setupVC = nil
        showNewDayChoice()
    }

    private func showTodayTabContent() {
        guard let vc = todayVC else { return }
        children.filter { $0 !== vc }.forEach {
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        addChild(vc)
        containerView.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            vc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        vc.didMove(toParent: self)
    }

    private func showMainContent() {
        todayVC = TodayViewController(viewModel: viewModel.makeTodayViewModel())
        calendarVC = CalendarViewController(viewModel: viewModel.makeCalendarViewModel())
        progressVC = ProgressViewController(viewModel: viewModel.makeProgressViewModel())
        switchToTab(.today)
    }

    private func switchToTab(_ tab: AppTab) {
        currentTab = tab
        let idx: Int
        switch tab {
        case .today: idx = 0
        case .calendar: idx = 1
        case .progress: idx = 2
        }
        customTabBar.selectedIndex = idx
        if tab == .today && viewModel.needsNewDayChoice {
            children.forEach {
                $0.view.removeFromSuperview()
                $0.removeFromParent()
            }
            showNewDayChoice()
            return
        }
        let target: UIViewController?
        switch tab {
        case .today: target = todayVC
        case .calendar: target = calendarVC
        case .progress: target = progressVC
        }
        guard let vc = target else { return }
        children.filter { $0 !== vc }.forEach {
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        if vc.parent == nil {
            addChild(vc)
            containerView.addSubview(vc.view)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                vc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                vc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            vc.didMove(toParent: self)
        }
    }
}
