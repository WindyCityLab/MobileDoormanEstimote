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
    @NSManaged var occupants : [PFUser]
    
    func addMeAsOccupant()
    {
        let query = Location.query()
        query?.whereKey("occupants", equalTo: PFUser.currentUser()!)
        query?.countObjectsInBackgroundWithBlock({ (result, error) -> Void in
            if error == nil
            {
                if result == 0
                {
                    self.occupants.append((PFUser.currentUser()!))
                    self.saveInBackground()
                }
            }
        })
    }
    
    func removeMeAsOccupant()
    {
        let query = Location.query()
        query?.whereKey("occupants", equalTo: PFUser.currentUser()!)
        query?.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            for location in results as! [Location]
            {
                if location.objectId == self.objectId
                {
                    var allOccupants = location.occupants
                    for i in 0 ..< location.occupants.count
                    {
                        if location.occupants[i].objectId == PFUser.currentUser()!.objectId
                        {
                            allOccupants.removeAtIndex(i)
                            break;
                        }
                    }
                    location.occupants = allOccupants
                    self.occupants = allOccupants
                    location.saveInBackground()
                }
            }
        })
    }
        
}