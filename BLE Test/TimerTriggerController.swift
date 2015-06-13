//
//  ControllerViewController.swift
//  Adafruit Bluefruit LE Connect
//
//  Created by Collin Cunningham on 11/25/14.
//  Copyright (c) 2014 Adafruit Industries. All rights reserved.
//

import UIKit

class TimerTriggerController: UIViewController, UITextFieldDelegate {
    
    var delegate:UARTViewControllerDelegate?
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    private let buttonPrefix = "!B"
    var timer:NSTimer!
    var seconds = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var appDelegate = UIApplication.sharedApplication().delegate as! BLEAppDelegate
        delegate = appDelegate.mainViewController!
        self.title = "Timer"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Stop updates if we're returning to main view
        timer.invalidate()
        
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
    @IBAction func shutterButtonPressed(sender:UIButton)
    {
        if seconds != 0
        {
            timer = NSTimer.scheduledTimerWithTimeInterval(seconds, target: self, selector: "fireShutter", userInfo: nil, repeats: false)
        }
    }
    
    func fireShutter()
    {
        var str = NSString(string:buttonPrefix + TIMELAPSE + "1" ) // a = basic mode
        var data = NSData(bytes: str.UTF8String, length: str.length)
        delegate?.sendData(appendCRC(data))
        println("triggered")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text != ""
        {
            seconds = (textField.text as NSString).doubleValue
            timeLabel.text = "\(seconds) seconds"
        }
        textField.resignFirstResponder()
        return true
    }
    
    
}