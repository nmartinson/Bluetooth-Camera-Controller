//
//  ControllerViewController.swift
//  Adafruit Bluefruit LE Connect
//
//  Created by Collin Cunningham on 11/25/14.
//  Copyright (c) 2014 Adafruit Industries. All rights reserved.
//

import UIKit

protocol ControllerViewControllerDelegate: HelpViewControllerDelegate {
    func sendData(newData:NSData)
}

class ControllerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var dataSource = ["Basic Trigger"]
    var delegate:UARTViewControllerDelegate?
    @IBOutlet var buttons:[UIButton]!
    @IBOutlet var exitButton:UIButton!
    @IBOutlet var controlTable:UITableView!

    private let buttonPrefix = "!B"    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Stop updates if we're returning to main view
        if self.isMovingFromParentViewController() {
            //Stop receiving app active notification
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        }
        
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    convenience init(aDelegate:UARTViewControllerDelegate){
        //Separate NIBs for iPhone 3.5", iPhone 4", & iPad
        var nibName:NSString
        
        if IS_IPHONE {
            nibName = "ControllerViewController_iPhone"
        }
        else{   //IPAD
            nibName = "ControllerViewController_iPad"
        }
        
        self.init(nibName: nibName as String, bundle: NSBundle.mainBundle())
        
        self.delegate = aDelegate
        self.title = "Controller"
    }
    
    
    //MARK: TableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        var buttonView:UIButton?
        
        cell.textLabel!.text = dataSource[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Camera Controller"
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let nib = dataSource[indexPath.row].stringByReplacingOccurrencesOfString(" ", withString: "").stringByAppendingString("Controller")
        let view = NSBundle.mainBundle().loadNibNamed(nib, owner: self, options: nil).first as! UIViewController

        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    func appendCRCmutable(data:NSMutableData) {
        //append crc
        var len = data.length
        var bdata = [UInt8](count: len, repeatedValue: 0)
        var buf = [UInt8](count: len, repeatedValue: 0)
        var crc:UInt8 = 0
        data.getBytes(&bdata, length: len)
        
        for i in bdata {    //add all bytes
            crc = crc &+ i
        }
        
        crc = ~crc  //invert
        
        data.appendBytes(&crc, length: 1)
    }
    
    func appendCRC(data:NSData)->NSMutableData {
        var mData = NSMutableData(length: 0)
        mData!.appendData(data)
        appendCRCmutable(mData!)
        return mData!
    }
    
}