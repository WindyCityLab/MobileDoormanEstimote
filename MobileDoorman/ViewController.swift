//
//  ViewController.swift
//  MobileDoorman
//
//  Created by Kevin McQuown on 3/16/16.
//  Copyright © 2016 Kevin McQuown. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ESTBeaconManagerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    var location : Location?
    let beaconManager = ESTBeaconManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 12314, minor: 30949, identifier: "monitored region")
    
    var occupants : [PFUser] = Array()
    
    @IBOutlet weak var inOutSwitch: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        NSNotificationCenter.defaultCenter().addObserverForName(kNotificationSilentPush, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.checkParse()
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkParse()
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
    
    func checkParse()
    {
        let query = Location.query()
        query?.includeKey("occupants")
        query?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            if let _ = error
            {
                print(error?.localizedDescription)
            }
            else
            {
                let test = object as! Location
                self.occupants.removeAll()
                for user in test.occupants
                {
                    self.occupants.append(user)
                    print(user.username)
                }
                self.title = String(self.occupants.count)
                self.tableView.reloadData()
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

    @IBAction func refreshTapped(sender: AnyObject) {
        checkParse()
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
}
extension ViewController
{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("basicCell")
        
        cell?.textLabel?.text = occupants[indexPath.row].username
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return occupants.count
    }
}

