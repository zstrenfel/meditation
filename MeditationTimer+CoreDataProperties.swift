//
//  MeditationTimer+CoreDataProperties.swift
//  
//
//  Created by Zach Strenfel on 3/13/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MeditationTimer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeditationTimer> {
        return NSFetchRequest<MeditationTimer>(entityName: "MeditationTimer");
    }

    @NSManaged public var countdown: Double
    @NSManaged public var countdown_sound: String?
    @NSManaged public var primary: Double
    @NSManaged public var primary_sound: String?
    @NSManaged public var cooldown: Double
    @NSManaged public var cooldown_sound: String?
    @NSManaged public var interval: Double
    @NSManaged public var interval_sound: String?
    @NSManaged public var created_at: NSDate?
    @NSManaged public var updated_at: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var meditation: NSOrderedSet?
}

// MARK: Generated accessors for meditation
extension MeditationTimer {

    @objc(insertObject:inMeditationAtIndex:)
    @NSManaged public func insertIntoMeditation(_ value: Meditation, at idx: Int)

    @objc(removeObjectFromMeditationAtIndex:)
    @NSManaged public func removeFromMeditation(at idx: Int)

    @objc(insertMeditation:atIndexes:)
    @NSManaged public func insertIntoMeditation(_ values: [Meditation], at indexes: NSIndexSet)

    @objc(removeMeditationAtIndexes:)
    @NSManaged public func removeFromMeditation(at indexes: NSIndexSet)

    @objc(replaceObjectInMeditationAtIndex:withObject:)
    @NSManaged public func replaceMeditation(at idx: Int, with value: Meditation)

    @objc(replaceMeditationAtIndexes:withMeditation:)
    @NSManaged public func replaceMeditation(at indexes: NSIndexSet, with values: [Meditation])

    @objc(addMeditationObject:)
    @NSManaged public func addToMeditation(_ value: Meditation)

    @objc(removeMeditationObject:)
    @NSManaged public func removeFromMeditation(_ value: Meditation)

    @objc(addMeditation:)
    @NSManaged public func addToMeditation(_ values: NSOrderedSet)

    @objc(removeMeditation:)
    @NSManaged public func removeFromMeditation(_ values: NSOrderedSet)
}

// 03/15/2017
extension MeditationTimer {
    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Date(), forKey: "created_at")
    }
}
