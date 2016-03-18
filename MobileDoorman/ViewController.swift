//
//  ViewController.swift
//  MobileDoorman
//
//  Created by Kevin McQuown on 3/16/16.
//  Copyright © 2016 Kevin McQuown. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ESTBeaconManagerDelegate {

    var location : Location?
    let beaconManager = ESTBeaconManager()
    var timer : NSTimer! = nil

    @IBOutlet weak var countLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        self.beaconManager.startMonitoringForRegion(CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 12314, minor: 30949, identifier: "monitored region"))
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
    }
    
    func timerFired(timer : NSTimer)
    {
        let query = Location.query()
        query?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            if let _ = error
            {
                print(error?.localizedDescription)
            }
            else
            {
                let test : Location = object as! Location
                self.countLabel.text = String(test.occupants)
            }
        })
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let query = Location.query()
        query?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            if let _ = error
            {
               print(error?.localizedDescription)
            }
            else
            {
                self.location = object as? Location
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func beaconManager(manager: AnyObject, didDetermineState state: CLRegionState, forRegion region: CLBeaconRegion) {
        print("Did determine state \(state.rawValue)")
    }
    
    func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        print("did enter")
        let notification = UILocalNotification()
        notification.alertBody = "We are in proximity of the beacon"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        location?.incrementOccupant()
    }
    
    func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
        print("did exit")
        let notification = UILocalNotification()
        notification.alertBody = "We no longer see the beacon"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        location?.decrementOccupant()
    }

}

