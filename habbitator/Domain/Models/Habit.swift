import Foundation

struct Habit: Identifiable, Equatable {
    let id: UUID
    let title: String
    let orderIndex: Int
    let createdAt: Date
}
