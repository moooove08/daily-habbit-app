import CoreData

@objc(HabitEntity)
public class HabitEntity: NSManagedObject {}

extension HabitEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitEntity> {
        return NSFetchRequest<HabitEntity>(entityName: "HabitEntity")
    }
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var isActive: Bool
    @NSManaged public var orderIndex: Int16
    @NSManaged public var createdAt: Date
}
