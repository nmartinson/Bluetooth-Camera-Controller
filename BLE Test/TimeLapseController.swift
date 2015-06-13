//
//  ControllerViewController.swift
//  Adafruit Bluefruit LE Connect
//
//  Created by Collin Cunningham on 11/25/14.
//  Copyright (c) 2014 Adafruit Industries. All rights reserved.
//

import UIKit

class TimeLapseController: UIViewController, UITextFieldDelegate {
    
    var delegate:UARTViewControllerDelegate?
    private let buttonPrefix = "!B"
    @IBOutlet weak var minIntervalLabel: UILabel!
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var exposureLabel: UILabel!
    @IBOutlet weak var exposureTextField: UITextField!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var intervalText: UITextField!
    @IBOutlet weak var framesLabel: UILabel!
    @IBOutlet weak var framesText: UITextField!
    @IBOutlet weak var framesFired: UILabel!
    var timer:NSTimer!
    var shutterSpeed:Double = 1/60
    var interval:Double = 15
    var frames:Int = 100
    var isShooting = false
    var framesShot = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var appDelegate = UIApplication.sharedApplication().delegate as! BLEAppDelegate
        delegate = appDelegate.mainViewController!
        intervalText.delegate = self
        self.title = "Time Lapse"
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
    @IBAction func shutterButtonPressed(sender:UIButton) {
        if !isShooting
        {
            timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "fireShutter", userInfo: nil, repeats: true)
            sender.setTitle("Stop", forState: .Normal)
            sender.backgroundColor = UIColor.redColor()
        }
        else
        {
            framesShot = 0
            timer.invalidate()
            sender.setTitle("Start", forState: .Normal)
            sender.backgroundColor = UIColor.blueColor()
        }
        isShooting = !isShooting
    }
    
    func fireShutter()
    {
        framesShot++
        if framesShot <= frames
        {
            framesFired.text = "Frames fired: \(framesShot)"
            var str = NSString(string:buttonPrefix + TIMELAPSE + "1" ) // a = basic mode
            var data = NSData(bytes: str.UTF8String, length: str.length)
            delegate?.sendData(appendCRC(data))
            str = NSString(string:buttonPrefix + TIMELAPSE + "0" ) // a = basic mode
            data = NSData(bytes: str.UTF8String, length: str.length)
            delegate?.sendData(appendCRC(data))
        }
        else
        {
            framesShot = 0
            framesFired.text = "Frames fired: \(framesShot)"
            timer.invalidate()
            shutterButton.setTitle("Start", forState: .Normal)
            shutterButton.backgroundColor = UIColor.blueColor()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == exposureTextField {
            shutterSpeed = (textField.text as NSString).doubleValue
            exposureLabel.text = "Shutter speed: \(shutterSpeed) s"
        }
        else if textField == intervalText {
            interval = (textField.text as NSString).doubleValue
            intervalLabel.text = "Interval between frames: \(interval) s"
        }
        else if textField == framesText {
            if textField.text != ""
            {
                frames = textField.text.toInt()!
            }
            framesLabel.text = "# of frames: \(frames)"
        }
        textField.resignFirstResponder()
        return false
    }
    

}