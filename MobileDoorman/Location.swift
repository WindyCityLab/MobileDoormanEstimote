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
    @NSManaged var beaconUUID : String
    @NSManaged var beaconMajor : NSNumber
    @NSManaged var beaconMinor : NSNumber
    @NSManaged var enabled : Bool
    
    func amInLocation() -> Bool
    {
        for u in self.occupants
        {
            if u.objectId == PFUser.currentUser()?.objectId
            {
                return true
            }
        }
        return false
    }
    
    class func locationQuery() -> PFQuery
    {
        let query = Location.query()
        query?.whereKey("enabled", equalTo: true)
        query?.includeKey("occupants")
        return query!
    }
    
    class func getLocations(complete: (locations : [Location]?, error : NSError?) -> Void)
    {
        locationQuery().findObjectsInBackgroundWithBlock({ (result, error) in
            var locations : [Location] = Array()
            if let objects = result
            {
                for object in objects
                {
                    locations.append(object as! Location)
                }
            }
            complete(locations: locations, error: error)
        })
    }
    
    func addMeAsOccupant(complete : () -> Void)
    {
        var found = false;
        for user in self.occupants
        {
            if user.objectId == PFUser.currentUser()!.objectId
            {
                found = true
                complete();
            }
        }
        if !found
        {
            self.occupants.append(PFUser.currentUser()!)
            self.saveInBackgroundWithBlock({ (result, error) in
                complete();
            })
        }
    }
    
    func removeMeAsOccupant(complete : () -> Void)
    {
        var allOccupants = self.occupants
        for i in 0 ..< self.occupants.count
        {
            if self.occupants[i].objectId == PFUser.currentUser()!.objectId
            {
                allOccupants.removeAtIndex(i)
                complete()
            }
        }
        self.occupants = allOccupants
        self.saveInBackgroundWithBlock({ (result, error) in
            complete()
        })
    }
    
}