//
//  ViewController.swift
//  MobileDoorman
//
//  Created by Kevin McQuown on 3/16/16.
//  Copyright © 2016 Kevin McQuown. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ESTBeaconManagerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    var location : Location?
    let beaconManager = ESTBeaconManager()
    var timer : NSTimer! = nil
    let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 12314, minor: 30949, identifier: "monitored region")
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var inOutSwitch: UISegmentedControl!
    
    func checkForLogin()
    {
        if PFUser.currentUser() == nil
        {
            let loginVC = PFLogInViewController()
            loginVC.delegate = self;
            
            let signUpVC = PFSignUpViewController()
            loginVC.signUpController = signUpVC;
            signUpVC.delegate = self
            presentViewController(loginVC, animated: true, completion: nil)
        }
        else
        {
            self.beaconManager.startMonitoringForRegion(region)
            
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inOutSwitch.selectedSegmentIndex = 0
        
        checkForLogin()
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            self.beaconManager.stopMonitoringForRegion(self.region)
            self.checkForLogin()
        }
    }
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        signUpController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.beaconManager.startMonitoringForRegion(region)
        logInController.dismissViewControllerAnimated(true, completion: nil)
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
                let test = object as! Location
                self.countLabel.text = String(test.occupants.count)
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
    
    @IBAction func button2Tapped(sender: AnyObject) {
        location?.removeMeAsOccupant()
    }
    @IBAction func buttonTapped(sender: AnyObject) {
        location?.addMeAsOccupant()
    }
    func beaconManager(manager: AnyObject, didDetermineState state: CLRegionState, forRegion region: CLBeaconRegion) {
        print("Did determine state \(state.rawValue)")
        inOutSwitch.selectedSegmentIndex = state.rawValue;
        switch state
        {
        case .Inside : location?.addMeAsOccupant()
        case .Outside: location?.removeMeAsOccupant()
        case .Unknown : ()
        }
    }
    
//    func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
//        print("did enter")
//        let notification = UILocalNotification()
//        notification.alertBody = "We are in proximity of the beacon"
//        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
//        location?.addMeAsOccupant()
//    }
//    
//    func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
//        print("did exit")
//        let notification = UILocalNotification()
//        notification.alertBody = "We no longer see the beacon"
//        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
//        location?.removeMeAsOccupant()
//    }

}

