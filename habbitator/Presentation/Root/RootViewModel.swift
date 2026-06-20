import Foundation

final class RootViewModel {
    private let repository: HabitRepository
    private let defaults: UserDefaults
    private let calendar: Calendar

    init(
        repository: HabitRepository,
        defaults: UserDefaults = .standard,
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.defaults = defaults
        self.calendar = calendar
    }

    var hasHabits: Bool {
        repository.hasAnyHabits()
    }

    var needsNewDayChoice: Bool {
        let today = calendar.startOfDay(for: Date())
        guard let lastChoiceDate = defaults.object(forKey: UserDefaultsKeys.lastHabitChoiceDate) as? Date else {
            defaults.set(today, forKey: UserDefaultsKeys.lastHabitChoiceDate)
            return false
        }
        return !calendar.isDate(today, inSameDayAs: lastChoiceDate)
    }

    func markHabitsChosenToday() {
        defaults.set(calendar.startOfDay(for: Date()), forKey: UserDefaultsKeys.lastHabitChoiceDate)
    }

    func keepCurrentHabits() {
        markHabitsChosenToday()
        repository.ensureDailyRecordsForTodayIfNeeded()
    }

    func makeSetupViewModel(isReplacing: Bool) -> SetupViewModel {
        SetupViewModel(repository: repository, isReplacing: isReplacing)
    }

    func makeTodayViewModel() -> TodayViewModel {
        TodayViewModel(repository: repository)
    }

    func makeCalendarViewModel() -> CalendarViewModel {
        CalendarViewModel(repository: repository)
    }

    func makeProgressViewModel() -> ProgressViewModel {
        ProgressViewModel(repository: repository)
    }
}
