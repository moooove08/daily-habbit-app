import UserNotifications

final class ReminderManager {
    static let shared = ReminderManager()
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func scheduleDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["daily"])
        guard UserDefaults.standard.bool(forKey: UserDefaultsKeys.reminderEnabled) else { return }
        let hour = UserDefaults.standard.object(forKey: UserDefaultsKeys.reminderHour) as? Int ?? 9
        let minute = UserDefaults.standard.object(forKey: UserDefaultsKeys.reminderMinute) as? Int ?? 0
        let content = UNMutableNotificationContent()
        content.title = "3 Habits a Day"
        content.body = "Don't forget to check today's habits"
        content.sound = .default
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily", content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }

    func updateSchedule() {
        scheduleDailyReminder()
    }
}
