import Foundation

struct DayDetailItem {
    let title: String
    let isCompleted: Bool
}

final class DayDetailViewModel {
    private let date: Date
    private let repository: HabitRepository
    private let calendar: Calendar
    private let dateFormatter: DateFormatter

    init(
        date: Date,
        repository: HabitRepository,
        calendar: Calendar = .current,
        dateFormatter: DateFormatter = DayDetailViewModel.makeDateFormatter()
    ) {
        self.date = date
        self.repository = repository
        self.calendar = calendar
        self.dateFormatter = dateFormatter
    }

    var dateText: String {
        dateFormatter.string(from: date)
    }

    func loadItems() -> [DayDetailItem] {
        let startOfDay = calendar.startOfDay(for: date)
        return repository.dailyRecords(for: startOfDay)
            .sorted { $0.habitID.uuidString < $1.habitID.uuidString }
            .map { record in
                DayDetailItem(
                    title: repository.habit(by: record.habitID)?.title ?? "Habit",
                    isCompleted: record.isCompleted
                )
            }
    }

    private static func makeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }
}
