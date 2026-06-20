import Foundation

protocol HabitRepository: AnyObject {
    func hasAnyHabits() -> Bool
    func createHabits(titles: [String])
    func replaceAllHabits(titles: [String])
    func ensureDailyRecordsForTodayIfNeeded()

    func activeHabits() -> [Habit]
    func habit(by id: UUID) -> Habit?
    func dailyRecords(for date: Date) -> [DailyRecord]
    func dailyRecord(date: Date, habitID: UUID) -> DailyRecord?
    func toggleCompletion(habitID: UUID)

    func completedCount(for date: Date) -> Int
    func isFullDay(_ date: Date) -> Bool
    func totalCompletedHabitsCount() -> Int
    func totalFullDaysCount() -> Int
    func currentFullStreak() -> Int
    func bestFullStreak() -> Int
    func currentWeekDates() -> [Date]
    func currentMonthDates() -> [Date]
    func refresh()
}
