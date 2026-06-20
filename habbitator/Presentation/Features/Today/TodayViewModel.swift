import Foundation

struct TodayHabitItem: Equatable {
    let id: UUID
    let title: String
    let isCompleted: Bool
}

struct TodayToggleResult {
    let item: TodayHabitItem
    let isFullDay: Bool
}

final class TodayViewModel {
    private let repository: HabitRepository
    private let calendar: Calendar
    private let dateFormatter: DateFormatter

    init(
        repository: HabitRepository,
        calendar: Calendar = .current,
        dateFormatter: DateFormatter = TodayViewModel.makeDateFormatter()
    ) {
        self.repository = repository
        self.calendar = calendar
        self.dateFormatter = dateFormatter
    }

    var dateText: String {
        dateFormatter.string(from: Date())
    }

    func loadItems() -> [TodayHabitItem] {
        repository.ensureDailyRecordsForTodayIfNeeded()
        let today = calendar.startOfDay(for: Date())
        return repository.activeHabits().map { habit in
            let record = repository.dailyRecord(date: today, habitID: habit.id)
            return TodayHabitItem(
                id: habit.id,
                title: habit.title,
                isCompleted: record?.isCompleted ?? false
            )
        }
    }

    func toggleHabit(id: UUID) -> TodayToggleResult? {
        repository.toggleCompletion(habitID: id)
        let today = calendar.startOfDay(for: Date())
        guard let habit = repository.habit(by: id) else { return nil }
        let record = repository.dailyRecord(date: today, habitID: id)
        return TodayToggleResult(
            item: TodayHabitItem(
                id: id,
                title: habit.title,
                isCompleted: record?.isCompleted ?? false
            ),
            isFullDay: repository.isFullDay(today)
        )
    }

    func praisePhrase() -> String {
        Self.praisePhrases.randomElement() ?? Self.praisePhrases[0]
    }

    private static func makeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }

    private static let praisePhrases = [
        "All three habits done! Nice work!",
        "Perfect day! You nailed it.",
        "Three out of three — keep it up! Congrats!",
        "Incredible! You're on fire today.",
        "Every checkbox is a win. You're crushing it!",
        "Day closed with a bang. Proud of you!",
        "All habits in the green — you're a star!",
        "You did it! Today is your day.",
        "Three habits — three wins. Bravo!",
        "Perfect! Keep it up every day."
    ]
}
