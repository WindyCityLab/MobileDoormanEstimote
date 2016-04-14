//
//  ViewController.swift
//  MobileDoorman
//
//  Created by Kevin McQuown on 3/16/16.
//  Copyright © 2016 Kevin McQuown. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ESTBeaconManagerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var locations : [Location] = Array()
    var regions : [CLBeaconRegion] = Array()

    let beaconManager = ESTBeaconManager()
        
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
            Location.getLocations({ (locations, error) in
                self.locations.removeAll()
                if let _ = locations
                {
                    for l in locations!
                    {
                        self.locations.append(l)
                        for u in l.occupants
                        {
                            print(u.username)
                        }
                        print("adding region \(l.name), \(l.beaconUUID),\(l.beaconMajor.unsignedShortValue),\(l.beaconMinor.unsignedShortValue)")
                        let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: l.beaconUUID)!, major: l.beaconMajor.unsignedShortValue   , minor: l.beaconMinor.unsignedShortValue, identifier: l.name)
                        self.regions.append(region)
                        self.beaconManager.startMonitoringForRegion(region)
                    }
                }
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        
        checkForLogin()
        
        NSNotificationCenter.defaultCenter().addObserverForName(kNotificationSilentPush, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.checkParse()
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.checkParse()
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            for r in self.regions
            {
                self.beaconManager.stopMonitoringForRegion(r)
            }
            self.checkForLogin()
        }
    }
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        signUpController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        for r in self.regions
        {
            self.beaconManager.startMonitoringForRegion(r)
        }
        logInController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkParse()
    {
        Location.getLocations({ (locations, error) in
            if error == nil
            {
                self.locations = locations!
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func refreshTapped(sender: AnyObject) {
        checkParse()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! OccupantViewController
        vc.location = locations[self.tableView.indexPathForSelectedRow!.row]
    }
}

extension ViewController
{
    func beaconManager(manager: AnyObject, didStartMonitoringForRegion region: CLBeaconRegion) {
        print ("did start monitoring \(region.identifier) \(region.proximityUUID) \(region.major) \(region.minor)")
    }
    func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        print ("did enter region")
        for l in locations
        {
            if l.name == region.identifier
            {
                l.addMeAsOccupant({ 
                    self.tableView.reloadData()
                })
            }
        }
    }
    func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
        print ("did exit region")
        for l in locations
        {
            if l.name == region.identifier
            {
                l.removeMeAsOccupant({ 
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func beaconManager(manager: AnyObject, didFailWithError error: NSError) {
        print ("failed with error \(error.localizedDescription)")
    }
    
    func beaconManager(manager: AnyObject, didDetermineState state: CLRegionState, forRegion region: CLBeaconRegion) {
        for l in locations
        {
            if l.name == region.identifier
            {
                print("Did determine state \(state.rawValue)")
                switch state
                {
                    case .Inside : l.addMeAsOccupant({
                        self.tableView.reloadData()
                    })
                    case .Outside: l.removeMeAsOccupant({
                        self.tableView.reloadData()
                    })
                    case .Unknown : ()
                }
            }
        }
    }
}
extension ViewController
{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("basicCell")
        
        let location = locations[indexPath.row]
        cell?.textLabel?.text = location.name
        cell?.detailTextLabel?.text = String(location.occupants.count)
        cell?.accessoryType = UITableViewCellAccessoryType.None
        
        if location.amInLocation()
        {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
}

