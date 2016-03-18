//
//  Location.swift
//  MobileDoorman
//
//  Created by Kevin McQuown on 3/17/16.
//  Copyright © 2016 Kevin McQuown. All rights reserved.
//

import Foundation

class Location : PFObject, PFSubclassing
{
    class func parseClassName() -> String {
        return "Location"
    }
    
    @NSManaged var name : String
    @NSManaged var occupants : NSNumber
    
    func incrementOccupant()
    {
        self.incrementKey("occupants", byAmount: 1)
        self.saveInBackground()
    }
    
    func decrementOccupant()
    {
        self.incrementKey("occupants", byAmount: -1)
        self.saveInBackground()
    }
    
}