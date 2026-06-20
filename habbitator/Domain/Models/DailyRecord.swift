import Foundation

struct DailyRecord: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let habitID: UUID
    let isCompleted: Bool
}
