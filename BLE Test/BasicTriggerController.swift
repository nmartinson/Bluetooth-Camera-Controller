//
//  ControllerViewController.swift
//  Adafruit Bluefruit LE Connect
//
//  Created by Collin Cunningham on 11/25/14.
//  Copyright (c) 2014 Adafruit Industries. All rights reserved.
//

import UIKit

class BasicTriggerController: UIViewController {
    
    var delegate:UARTViewControllerDelegate?    
    private let buttonPrefix = "!B"
    //    private let sensorQueue = dispatch_queue_create("com.adafruit.bluefruitconnect.sensorQueue", DISPATCH_QUEUE_SERIAL)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var appDelegate = UIApplication.sharedApplication().delegate as! BLEAppDelegate
        delegate = appDelegate.mainViewController!
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
    
    //MARK: Shutter Button
    @IBAction func shutterButtonPressed(sender:UIButton) {
        sender.backgroundColor = UIColor.blueColor()
        println(sender.tag)
        var str = NSString(string:buttonPrefix + "a" + "1" ) // a = basic mode
        let data = NSData(bytes: str.UTF8String, length: str.length)
        
        delegate?.sendData(appendCRC(data))
    }
    
    @IBAction func shutterButtonReleased(sender:UIButton) {
        
        sender.backgroundColor = UIColor.redColor()
        var str = NSString(string:buttonPrefix + "a" + "0") // a = basic mode
        let data = NSData(bytes: str.UTF8String, length: str.length)
        
        delegate?.sendData(appendCRC(data))
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