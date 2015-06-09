//
//  ControllerViewController.swift
//  Adafruit Bluefruit LE Connect
//
//  Created by Collin Cunningham on 11/25/14.
//  Copyright (c) 2014 Adafruit Industries. All rights reserved.
//

import UIKit
import CoreMotion

protocol ControllerViewControllerDelegate: HelpViewControllerDelegate {
    
    func sendData(newData:NSData)
    
}

class ControllerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var delegate:UARTViewControllerDelegate?
    @IBOutlet var helpViewController:HelpViewController!
    @IBOutlet var controlPadViewController:UIViewController!
    @IBOutlet var buttons:[UIButton]!
    @IBOutlet var exitButton:UIButton!
    @IBOutlet var controlTable:UITableView!
    @IBOutlet var valueCell:SensorValueCell!
    
//    var accelButton:BLESensorButton!
    var buttonColor:UIColor!
    var exitButtonColor:UIColor!

    private let buttonPrefix = "!B"
//    private let sensorQueue = dispatch_queue_create("com.adafruit.bluefruitconnect.sensorQueue", DISPATCH_QUEUE_SERIAL)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setup help view
        self.helpViewController.title = "Controller Help"
        self.helpViewController.delegate = delegate
    
        //button stuff
        buttonColor = buttons[0].backgroundColor
        exitButtonColor = exitButton.backgroundColor
        exitButton.layer.cornerRadius = 4.0

        //Register to be notified when app returns to active
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("checkLocationServices"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        var buttonView:UIButton?
        
        if indexPath.section == 0{
            cell.textLabel!.text = "Control Pad"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = UITableViewCellSelectionStyle.Blue
            return cell
        }
        else {
            cell.textLabel?.text = "Control Pad"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = UITableViewCellSelectionStyle.Blue
            return cell
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 44.0
        }
        else {
            return 28.0
        }
        
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.5
        
    }
    
    
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        
        if indexPath.row == 0 {
            return 0
        }
        
        else {
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "Camera Controller"
        }
        
        else {
            return nil
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            self.navigationController?.pushViewController(controlPadViewController, animated: true)
            
            if IS_IPHONE {  //Hide nav bar on iphone to conserve space
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }
        }
        
    }
    
    
    //MARK: Control Pad
    
    @IBAction func controlPadButtonPressed(sender:UIButton) {
        sender.backgroundColor = cellSelectionColor
        
        var str = NSString(string: buttonPrefix + "\(sender.tag)" + "1")
        let data = NSData(bytes: str.UTF8String, length: str.length)
        
        delegate?.sendData(appendCRC(data))
    
    }
    
    
    @IBAction func controlPadButtonReleased(sender:UIButton) {
        
        sender.backgroundColor = buttonColor
        
        var str = NSString(string: buttonPrefix + "\(sender.tag)" + "0")
        let data = NSData(bytes: str.UTF8String, length: str.length)
        
        delegate?.sendData(appendCRC(data))
    }
    
    @IBAction func controlPadExitPressed(sender:UIButton) {
        
        sender.backgroundColor = buttonColor
    }
    
    @IBAction func controlPadExitReleased(sender:UIButton) {
        
        sender.backgroundColor = exitButtonColor
        navigationController?.popViewControllerAnimated(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func controlPadExitDragOutside(sender:UIButton) {
        sender.backgroundColor = exitButtonColor
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
    
    
    
    func helpViewControllerDidFinish(controller : HelpViewController) {
        
        delegate?.helpViewControllerDidFinish(controller)
        
    }
    
    
}