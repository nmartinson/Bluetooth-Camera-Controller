//
//  ControllerViewController.swift
//  Adafruit Bluefruit LE Connect
//
//  Created by Collin Cunningham on 11/25/14.
//  Copyright (c) 2014 Adafruit Industries. All rights reserved.
//

import UIKit

class SimpleTriggerController: UIViewController {
    
    var delegate:UARTViewControllerDelegate?
    var buttonColor:UIColor!
    var exitButtonColor:UIColor!
    
    private let buttonPrefix = "!B"
    //    private let sensorQueue = dispatch_queue_create("com.adafruit.bluefruitconnect.sensorQueue", DISPATCH_QUEUE_SERIAL)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Basic trigger Loaded")
        //setup help view
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
    
    
    //    convenience init(aDelegate:UARTViewControllerDelegate){
    //
    //        //Separate NIBs for iPhone 3.5", iPhone 4", & iPad
    //
    //        var nibName:NSString
    //
    ////        if IS_IPHONE {
    //            nibName = "BasicTriggerController"
    ////        }
    ////        else{   //IPAD
    ////            nibName = "ControllerViewController_iPad"
    ////        }
    //
    //        self.init(nibName: nibName as String, bundle: NSBundle.mainBundle())
    //
    //        self.delegate = aDelegate
    //        self.title = "Basic Trigger"
    //    }
    
    
    
    
    //MARK: Control Pad
    
    @IBAction func Pressed(sender: AnyObject) {
        println("Pressed")
    }
    
    @IBAction func shutterButtonPressed(sender:UIButton) {
        sender.backgroundColor = cellSelectionColor
        
        var str = NSString(string: buttonPrefix + "\(sender.tag)" + "1")
        let data = NSData(bytes: str.UTF8String, length: str.length)
        
        delegate?.sendData(appendCRC(data))
        
    }
    
    
    @IBAction func shutterButtonReleased(sender:UIButton) {
        
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