import Foundation
import CoreData

final class CoreDataHabitRepository: HabitRepository {
    private let stack: HabitCoreDataStack

    init(stack: HabitCoreDataStack) {
        self.stack = stack
    }

    func hasAnyHabits() -> Bool {
        stack.hasAnyHabits()
    }

    func createHabits(titles: [String]) {
        stack.createHabits(titles: titles)
    }

    func replaceAllHabits(titles: [String]) {
        stack.replaceAllHabits(titles: titles)
    }

    func ensureDailyRecordsForTodayIfNeeded() {
        stack.ensureDailyRecordsForTodayIfNeeded()
    }

    func activeHabits() -> [Habit] {
        stack.fetchActiveHabits().map {
            Habit(
                id: $0.id,
                title: $0.title,
                orderIndex: Int($0.orderIndex),
                createdAt: $0.createdAt
            )
        }
    }

    func habit(by id: UUID) -> Habit? {
        guard let entity = stack.fetchHabit(by: id) else { return nil }
        return Habit(
            id: entity.id,
            title: entity.title,
            orderIndex: Int(entity.orderIndex),
            createdAt: entity.createdAt
        )
    }

    func dailyRecords(for date: Date) -> [DailyRecord] {
        var records: [DailyRecord] = []
        for entity in stack.fetchDailyRecords(for: date) {
            records.append(Self.makeDailyRecord(from: entity))
        }
        return records
    }

    func dailyRecord(date: Date, habitID: UUID) -> DailyRecord? {
        guard let entity = stack.fetchDailyRecord(date: date, habitID: habitID) else { return nil }
        return Self.makeDailyRecord(from: entity)
    }

    func toggleCompletion(habitID: UUID) {
        stack.toggleCompletion(habitID: habitID)
    }

    func completedCount(for date: Date) -> Int {
        stack.completedCount(for: date)
    }

    func isFullDay(_ date: Date) -> Bool {
        stack.isFullDay(date)
    }

    func totalCompletedHabitsCount() -> Int {
        stack.totalCompletedHabitsCount()
    }

    func totalFullDaysCount() -> Int {
        stack.totalFullDaysCount()
    }

    func currentFullStreak() -> Int {
        stack.currentStreakFull()
    }

    func bestFullStreak() -> Int {
        stack.bestStreakFull()
    }

    func currentWeekDates() -> [Date] {
        stack.currentWeekDates()
    }

    func currentMonthDates() -> [Date] {
        stack.currentMonthDates()
    }

    func refresh() {
        stack.viewContext.processPendingChanges()
    }

    private static func makeDailyRecord(from entity: DailyRecordEntity) -> DailyRecord {
        DailyRecord(
            id: entity.id,
            date: entity.date,
            habitID: entity.habitID,
            isCompleted: entity.isCompleted
        )
    }
}
