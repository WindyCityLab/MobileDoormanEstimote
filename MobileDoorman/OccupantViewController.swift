//
//  OccupantViewController.swift
//  MobileDoorman
//
//  Created by Kevin McQuown on 4/14/16.
//  Copyright © 2016 Kevin McQuown. All rights reserved.
//

import UIKit

class OccupantViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var location : Location? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addUser(sender: AnyObject) {
        location?.addMeAsOccupant({ 
            self.tableView.reloadData()
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension OccupantViewController
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (location?.occupants.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell")
        let user = location?.occupants[indexPath.row]
        cell?.textLabel?.text = user?.username
        return cell!
    }
}