import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let coreDataStack = HabitCoreDataStack()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ReminderManager.shared.updateSchedule()
        coreDataStack.loadPersistentStore { [weak self] in
            guard let self = self else { return }
            let repository = CoreDataHabitRepository(stack: self.coreDataStack)
            let rootViewModel = RootViewModel(repository: repository)
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = RootViewController(viewModel: rootViewModel)
            self.window?.makeKeyAndVisible()
        }
        return true
    }
}
