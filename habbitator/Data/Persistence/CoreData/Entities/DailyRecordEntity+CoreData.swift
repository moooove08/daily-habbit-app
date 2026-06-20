import CoreData

@objc(DailyRecordEntity)
public class DailyRecordEntity: NSManagedObject {}

extension DailyRecordEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyRecordEntity> {
        return NSFetchRequest<DailyRecordEntity>(entityName: "DailyRecordEntity")
    }
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var isCompleted: Bool
    @NSManaged public var habitID: UUID
}
