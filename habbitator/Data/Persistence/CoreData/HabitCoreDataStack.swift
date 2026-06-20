import CoreData
import Foundation

enum CalendarDayState {
    case empty
    case partial
    case full
}

final class HabitCoreDataStack {
    static let modelName = "habbitator"

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let habitEntity = NSEntityDescription()
        habitEntity.name = "HabitEntity"
        habitEntity.managedObjectClassName = "HabitEntity"
        habitEntity.properties = [
            { let a = NSAttributeDescription(); a.name = "id"; a.attributeType = .UUIDAttributeType; a.isOptional = false; return a }(),
            { let a = NSAttributeDescription(); a.name = "title"; a.attributeType = .stringAttributeType; a.isOptional = false; return a }(),
            { let a = NSAttributeDescription(); a.name = "isActive"; a.attributeType = .booleanAttributeType; a.defaultValue = false; return a }(),
            { let a = NSAttributeDescription(); a.name = "orderIndex"; a.attributeType = .integer16AttributeType; a.defaultValue = 0; return a }(),
            { let a = NSAttributeDescription(); a.name = "createdAt"; a.attributeType = .dateAttributeType; a.isOptional = false; return a }()
        ]
        let dailyEntity = NSEntityDescription()
        dailyEntity.name = "DailyRecordEntity"
        dailyEntity.managedObjectClassName = "DailyRecordEntity"
        dailyEntity.properties = [
            { let a = NSAttributeDescription(); a.name = "id"; a.attributeType = .UUIDAttributeType; a.isOptional = false; return a }(),
            { let a = NSAttributeDescription(); a.name = "date"; a.attributeType = .dateAttributeType; a.isOptional = false; return a }(),
            { let a = NSAttributeDescription(); a.name = "isCompleted"; a.attributeType = .booleanAttributeType; a.defaultValue = false; return a }(),
            { let a = NSAttributeDescription(); a.name = "habitID"; a.attributeType = .UUIDAttributeType; a.isOptional = false; return a }()
        ]
        model.entities = [habitEntity, dailyEntity]
        return model
    }

    private var _container: NSPersistentContainer?
    var persistentContainer: NSPersistentContainer {
        if let c = _container { return c }
        fatalError("Core Data not loaded. Call loadPersistentStore(completion:) first.")
    }

    func loadPersistentStore(completion: @escaping () -> Void) {
        guard _container == nil else { completion(); return }
        let container = NSPersistentContainer(name: Self.modelName, managedObjectModel: Self.makeModel())
        let fm = FileManager.default
        let docsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storeURL = docsURL.appendingPathComponent("\(Self.modelName).sqlite")
        let desc = NSPersistentStoreDescription(url: storeURL)
        desc.setOption(NSNumber(value: true), forKey: NSMigratePersistentStoresAutomaticallyOption)
        desc.setOption(NSNumber(value: true), forKey: NSInferMappingModelAutomaticallyOption)
        container.persistentStoreDescriptions = [desc]
        let finish: () -> Void = { [weak self] in
            self?._container = container
            self?.ensureDailyRecordsForTodayIfNeeded()
            DispatchQueue.main.async { completion() }
        }
        container.loadPersistentStores { [weak self] _, error in
            if let _ = error {
                try? fm.removeItem(at: storeURL)
                try? fm.removeItem(at: URL(fileURLWithPath: storeURL.path + "-shm"))
                try? fm.removeItem(at: URL(fileURLWithPath: storeURL.path + "-wal"))
                container.loadPersistentStores { _, retryError in
                    if retryError != nil {
                        container.persistentStoreDescriptions = [{
                            let d = NSPersistentStoreDescription()
                            d.type = NSInMemoryStoreType
                            return d
                        }()]
                        container.loadPersistentStores { _, _ in
                            self?._container = container
                            self?.ensureDailyRecordsForTodayIfNeeded()
                            DispatchQueue.main.async { completion() }
                        }
                    } else {
                        finish()
                    }
                }
            } else {
                finish()
            }
        }
    }

    var viewContext: NSManagedObjectContext { persistentContainer.viewContext }

    func saveContext() {
        let ctx = viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    func hasAnyHabits() -> Bool {
        let req = HabitEntity.fetchRequest()
        req.fetchLimit = 1
        do {
            return try viewContext.count(for: req) > 0
        } catch {
            return false
        }
    }

    func createHabits(titles: [String]) {
        guard titles.count == 3 else { return }
        let now = Date()
        for (idx, title) in titles.enumerated() {
            let h = HabitEntity(context: viewContext)
            h.id = UUID()
            h.title = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Habit \(idx + 1)" : title
            h.isActive = true
            h.orderIndex = Int16(idx)
            h.createdAt = now
        }
        saveContext()
        ensureDailyRecordsForTodayIfNeeded()
    }

    func deactivateAllHabits() {
        let habits = fetchActiveHabits()
        for h in habits {
            h.isActive = false
        }
        saveContext()
    }

    func replaceAllHabits(titles: [String]) {
        guard titles.count == 3 else { return }
        let oldActiveIDs = fetchActiveHabits().map { $0.id }
        deactivateAllHabits()
        deleteDailyRecords(for: Calendar.current.startOfDay(for: Date()), habitIDs: oldActiveIDs)
        createHabits(titles: titles)
    }

    private func deleteDailyRecords(for date: Date, habitIDs: [UUID]) {
        guard !habitIDs.isEmpty else { return }
        let start = Calendar.current.startOfDay(for: date)
        let records = fetchDailyRecords(for: start)
        let idSet = Set(habitIDs)
        for r in records where idSet.contains(r.habitID) {
            viewContext.delete(r)
        }
        saveContext()
    }

    func ensureDailyRecordsForTodayIfNeeded() {
        let habits = fetchActiveHabits()
        guard !habits.isEmpty else { return }
        let today = Calendar.current.startOfDay(for: Date())
        for habit in habits {
            if fetchDailyRecord(date: today, habitID: habit.id) == nil {
                let r = DailyRecordEntity(context: viewContext)
                r.id = UUID()
                r.date = today
                r.habitID = habit.id
                r.isCompleted = false
            }
        }
        saveContext()
    }

    func fetchActiveHabits() -> [HabitEntity] {
        let req = HabitEntity.fetchRequest()
        req.predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        req.sortDescriptors = [NSSortDescriptor(keyPath: \HabitEntity.orderIndex, ascending: true)]
        do {
            return try viewContext.fetch(req)
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }

    func fetchHabit(by id: UUID) -> HabitEntity? {
        let req = HabitEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        req.fetchLimit = 1
        return try? viewContext.fetch(req).first
    }

    func fetchDailyRecords(for date: Date) -> [DailyRecordEntity] {
        let start = Calendar.current.startOfDay(for: date)
        let req = DailyRecordEntity.fetchRequest()
        req.predicate = NSPredicate(format: "date == %@", start as NSDate)
        do {
            return try viewContext.fetch(req)
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }

    func fetchDailyRecord(date: Date, habitID: UUID) -> DailyRecordEntity? {
        let start = Calendar.current.startOfDay(for: date)
        let req = DailyRecordEntity.fetchRequest()
        req.predicate = NSPredicate(format: "date == %@ AND habitID == %@", start as NSDate, habitID as CVarArg)
        req.fetchLimit = 1
        do {
            return try viewContext.fetch(req).first
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }

    func toggleCompletion(habitID: UUID) {
        let today = Calendar.current.startOfDay(for: Date())
        ensureDailyRecordsForTodayIfNeeded()
        var record = fetchDailyRecord(date: today, habitID: habitID)
        if record == nil {
            let r = DailyRecordEntity(context: viewContext)
            r.id = UUID()
            r.date = today
            r.habitID = habitID
            r.isCompleted = false
            saveContext()
            record = fetchDailyRecord(date: today, habitID: habitID)
        }
        guard let rec = record else { return }
        rec.isCompleted.toggle()
        saveContext()
    }

    func calendarState(for date: Date) -> CalendarDayState {
        let records = fetchDailyRecords(for: date)
        let completed = records.filter { $0.isCompleted }.count
        let total = records.count
        if total == 0 { return .empty }
        if completed == total && total == 3 { return .full }
        if completed > 0 { return .partial }
        return .empty
    }

    private func activeHabitIDs() -> Set<UUID> {
        Set(fetchActiveHabits().map { $0.id })
    }

    func completedCount(for date: Date) -> Int {
        let start = Calendar.current.startOfDay(for: date)
        let todayStart = Calendar.current.startOfDay(for: Date())
        var records = fetchDailyRecords(for: start)
        if start == todayStart {
            let activeIDs = activeHabitIDs()
            records = records.filter { activeIDs.contains($0.habitID) }
        }
        return records.filter { $0.isCompleted }.count
    }

    func isFullDay(_ date: Date) -> Bool {
        let start = Calendar.current.startOfDay(for: date)
        let todayStart = Calendar.current.startOfDay(for: Date())
        if start == todayStart {
            let habits = fetchActiveHabits()
            guard habits.count == 3 else { return false }
            for habit in habits {
                guard let rec = fetchDailyRecord(date: start, habitID: habit.id), rec.isCompleted else { return false }
            }
            return true
        }
        let records = fetchDailyRecords(for: start)
        return records.count == 3 && records.allSatisfy { $0.isCompleted }
    }

    func currentStreakFull() -> Int {
        let cal = Calendar.current
        var day = cal.startOfDay(for: Date())
        var count = 0
        while true {
            if isFullDay(day) {
                count += 1
                day = cal.date(byAdding: .day, value: -1, to: day) ?? day
            } else {
                break
            }
        }
        return count
    }

    func bestStreakFull() -> Int {
        let req = DailyRecordEntity.fetchRequest()
        do {
            let records = try viewContext.fetch(req)
            let cal = Calendar.current
            let fullDates = Set(records.map { cal.startOfDay(for: $0.date) }).filter { isFullDay($0) }
            let sorted = fullDates.sorted()
            guard !sorted.isEmpty else { return 0 }
            var maxStreak = 1
            var current = 1
            for i in 1..<sorted.count {
                let prev = sorted[i - 1]
                let curr = sorted[i]
                if let next = cal.date(byAdding: .day, value: 1, to: prev), next == curr {
                    current += 1
                    maxStreak = max(maxStreak, current)
                } else {
                    current = 1
                }
            }
            return maxStreak
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }

    func totalCompletedHabitsCount() -> Int {
        let req = DailyRecordEntity.fetchRequest()
        req.predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: true))
        do {
            return try viewContext.count(for: req)
        } catch {
            return 0
        }
    }

    func totalFullDaysCount() -> Int {
        let req = DailyRecordEntity.fetchRequest()
        req.predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: true))
        do {
            let records = try viewContext.fetch(req)
            let cal = Calendar.current
            let dates = Set(records.map { cal.startOfDay(for: $0.date) })
            return dates.filter { isFullDay($0) }.count
        } catch {
            return 0
        }
    }

    func currentWeekDates() -> [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let first = cal.firstWeekday
        var offset = weekday - first
        if offset < 0 { offset += 7 }
        guard let weekStart = cal.date(byAdding: .day, value: -offset, to: today) else { return [] }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: weekStart) }
    }

    func currentMonthDates() -> [Date] {
        let cal = Calendar.current
        let today = Date()
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: today))!
        guard let range = cal.range(of: .day, in: .month, for: startOfMonth) else { return [] }
        return range.compactMap { cal.date(bySetting: .day, value: $0, of: startOfMonth) }
    }

    func currentStreak() -> Int {
        let cal = Calendar.current
        var day = cal.startOfDay(for: Date())
        var count = 0
        while true {
            let records = fetchDailyRecords(for: day)
            if records.filter({ $0.isCompleted }).count >= 1 {
                count += 1
                day = cal.date(byAdding: .day, value: -1, to: day) ?? day
            } else {
                break
            }
        }
        return count
    }

    func bestStreak() -> Int {
        let req = DailyRecordEntity.fetchRequest()
        req.predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: true))
        do {
            let records = try viewContext.fetch(req)
            let cal = Calendar.current
            let dates = Set(records.map { cal.startOfDay(for: $0.date) })
            let sorted = dates.sorted()
            guard !sorted.isEmpty else { return 0 }
            var maxStreak = 1
            var current = 1
            for i in 1..<sorted.count {
                let prev = sorted[i - 1]
                let curr = sorted[i]
                if let next = cal.date(byAdding: .day, value: 1, to: prev), next == curr {
                    current += 1
                    maxStreak = max(maxStreak, current)
                } else {
                    current = 1
                }
            }
            return maxStreak
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }

    func completedCountsForLastDays(_ days: Int) -> [Int] {
        let cal = Calendar.current
        var today = cal.startOfDay(for: Date())
        var result: [Int] = []
        for _ in 0..<days {
            result.append(completedCount(for: today))
            today = cal.date(byAdding: .day, value: -1, to: today) ?? today
        }
        return result
    }

    func updateHabitTitle(habitID: UUID, title: String) {
        let req = HabitEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", habitID as CVarArg)
        req.fetchLimit = 1
        guard let h = try? viewContext.fetch(req).first else { return }
        h.title = title
        saveContext()
    }

    func replaceHabit(oldHabitID: UUID, newTitle: String) {
        let req = HabitEntity.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", oldHabitID as CVarArg)
        req.fetchLimit = 1
        guard let oldH = try? viewContext.fetch(req).first else { return }
        let active = fetchActiveHabits()
        guard let idx = active.firstIndex(where: { $0.id == oldHabitID }) else { return }
        oldH.isActive = false
        let newH = HabitEntity(context: viewContext)
        newH.id = UUID()
        newH.title = newTitle
        newH.isActive = true
        newH.orderIndex = Int16(idx)
        newH.createdAt = Date()
        saveContext()
        ensureDailyRecordsForTodayIfNeeded()
    }
}
