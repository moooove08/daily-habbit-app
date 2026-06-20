import Foundation

struct ProgressViewData {
    let totalCompletedHabits: Int
    let totalFullDays: Int
    let currentFullStreak: Int
    let bestFullStreak: Int
    let weekDates: [Date]
    let weekFilled: [Bool]
    let monthDates: [Date]
    let monthFilled: [Bool]
}

final class ProgressViewModel {
    private let repository: HabitRepository

    init(repository: HabitRepository) {
        self.repository = repository
    }

    func load() -> ProgressViewData {
        repository.refresh()
        let weekDates = repository.currentWeekDates()
        let monthDates = repository.currentMonthDates()
        return ProgressViewData(
            totalCompletedHabits: repository.totalCompletedHabitsCount(),
            totalFullDays: repository.totalFullDaysCount(),
            currentFullStreak: repository.currentFullStreak(),
            bestFullStreak: repository.bestFullStreak(),
            weekDates: weekDates,
            weekFilled: weekDates.map(repository.isFullDay),
            monthDates: monthDates,
            monthFilled: monthDates.map(repository.isFullDay)
        )
    }
}
