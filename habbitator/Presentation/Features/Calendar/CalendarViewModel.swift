import Foundation

struct CalendarDayItem {
    let date: Date
    let dayNumber: Int
    let completedCount: Int
}

struct CalendarMonthViewData {
    let title: String
    let leadingEmptyDays: Int
    let days: [CalendarDayItem]
}

final class CalendarViewModel {
    private let repository: HabitRepository
    private let calendar: Calendar
    private let formatter: DateFormatter
    private var currentMonth: Date

    init(
        repository: HabitRepository,
        calendar: Calendar = .current,
        formatter: DateFormatter = CalendarViewModel.makeMonthFormatter()
    ) {
        self.repository = repository
        self.calendar = calendar
        self.formatter = formatter
        self.currentMonth = calendar.startOfDay(for: Date())
    }

    func loadMonth() -> CalendarMonthViewData {
        repository.refresh()
        guard
            let range = calendar.range(of: .day, in: .month, for: currentMonth),
            let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))
        else {
            return CalendarMonthViewData(title: formatter.string(from: currentMonth), leadingEmptyDays: 0, days: [])
        }

        var emptyDays = calendar.component(.weekday, from: firstDay) - calendar.firstWeekday
        if emptyDays < 0 { emptyDays += 7 }

        let days = range.compactMap { day -> CalendarDayItem? in
            guard let date = calendar.date(bySetting: .day, value: day, of: currentMonth) else { return nil }
            return CalendarDayItem(
                date: date,
                dayNumber: day,
                completedCount: repository.completedCount(for: date)
            )
        }
        return CalendarMonthViewData(
            title: formatter.string(from: currentMonth),
            leadingEmptyDays: emptyDays,
            days: days
        )
    }

    func showPreviousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    func showNextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }

    func makeDayDetailViewModel(for date: Date) -> DayDetailViewModel {
        DayDetailViewModel(date: date, repository: repository, calendar: calendar)
    }

    private static func makeMonthFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}
