//
//  Meditation+CoreDataProperties.swift
//  
//
//  Created by Zach Strenfel on 3/13/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Meditation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meditation> {
        return NSFetchRequest<Meditation>(entityName: "Meditation");
    }

    @NSManaged public var created_at: NSDate?
    @NSManaged public var updated_at: NSDate?
    @NSManaged public var completed: Bool
    @NSManaged public var notes: String?
    @NSManaged public var timer: MeditationTimer?

}
