import Foundation

final class SetupViewModel {
    let isReplacing: Bool
    private let repository: HabitRepository

    init(repository: HabitRepository, isReplacing: Bool) {
        self.repository = repository
        self.isReplacing = isReplacing
    }

    func canContinue(with titles: [String]) -> Bool {
        titles.count == 3 && titles.allSatisfy {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    func randomTitles() -> [String] {
        Array(Self.defaultHabits.shuffled().prefix(3))
    }

    func save(titles: [String]) {
        if isReplacing {
            repository.replaceAllHabits(titles: titles)
        } else {
            repository.createHabits(titles: titles)
        }
    }

    func motivatingPhrase() -> String {
        Self.motivatingPhrases.randomElement() ?? Self.motivatingPhrases[0]
    }

    private static let defaultHabits = [
        "Drink water",
        "Do some exercise",
        "Take a short walk",
        "Read for 10 minutes",
        "Stretch",
        "Eat a healthy meal",
        "Get enough sleep",
        "Meditate or breathe",
        "Tidy one area",
        "Write 3 things you're grateful for",
        "Limit screen time",
        "Call or message someone",
        "Learn something new",
        "Take vitamins",
        "Go to bed on time",
        "Eat breakfast",
        "Take a break outside",
        "Do one household chore",
        "Practice a hobby",
        "Review your day"
    ]

    private static let motivatingPhrases = [
        "Great start! You're already on your way to a better you.",
        "Three habits — three steps toward your goal. You've got this!",
        "Every day begins with a choice. You made the right one.",
        "Small steps every day create big changes.",
        "You took the leap — that's already a win. Let's go!",
        "From today onward, things are different. Good luck!",
        "Three habits a day is a solid plan. You can do it!",
        "You've laid the foundation. Now — action.",
        "You're off to a strong start. Keep it up!",
        "Your plan for the day is set. All that's left is to do it!"
    ]
}
