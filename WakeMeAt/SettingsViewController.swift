//
//  SettingsViewController.swift
//  WakeMeAt
//
//  Created by Ivy Chenyao on 11/17/16.
//  Copyright © 2016 Ivy Chenyao. All rights reserved.
//

// TODO: Make sure other View Controller still running when user is in Settings

import UIKit
import AudioToolbox
import MediaPlayer
import AVFoundation // Has the code to allow us to use iPhone's speakers

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var alarmSoundChoices: UIPickerView!
    @IBOutlet weak var radius: UITextField!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var vibrationSlider: UISlider?
    @IBOutlet weak var stepper: UIStepper?
    @IBOutlet weak var stepperValue: UILabel!
    
    var radiusValue = 5.0
    
//    // Alarm sound choices and path URLs
//    var alarmBuzzerPlayer = AVAudioPlayer()
//    var alarmBuzzerURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Alarm Buzzer", ofType: "mp3")!)
//    
//    var policeSirenPlayer = AVAudioPlayer()
//    var policeSirenURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Police Siren", ofType: "mp3")!)
//    
//    var doorbellPlayer = AVAudioPlayer()
//    var doorbellURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Doorbell", ofType: "mp3")!)
//    
//    var ambulancePlayer = AVAudioPlayer()
//    var ambulanceURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Ambulance", ofType: "mp3")!)
//    
//    var hornHonkPlayer = AVAudioPlayer()
//    var hornHonkURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Horn Honk", ofType: "mp3")!)
//    
//    var fireAlarmPlayer = AVAudioPlayer()
//    var fireAlarmURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Fire Alarm", ofType: "mp3")!)
//    
//    var alarmSoundChoicesData: [String] = [String]()
    //var alarmSound = AVAudioPlayer()
    //var alarmSound: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        
        // Loads alarm sound choices
        do {
            Sounds.sharedInstance.alarmBuzzerPlayer = try AVAudioPlayer(contentsOf: Sounds.sharedInstance.alarmBuzzerURL as URL)
            Sounds.sharedInstance.policeSirenPlayer = try AVAudioPlayer(contentsOf: Sounds.sharedInstance.policeSirenURL as URL)
            Sounds.sharedInstance.doorbellPlayer = try AVAudioPlayer(contentsOf: Sounds.sharedInstance.doorbellURL as URL)
            Sounds.sharedInstance.ambulancePlayer = try AVAudioPlayer(contentsOf: Sounds.sharedInstance.ambulanceURL as URL)
            Sounds.sharedInstance.hornHonkPlayer = try AVAudioPlayer(contentsOf: Sounds.sharedInstance.hornHonkURL as URL)
            Sounds.sharedInstance.fireAlarmPlayer = try AVAudioPlayer(contentsOf: Sounds.sharedInstance.fireAlarmURL as URL)
        } catch let error {
            print(error.localizedDescription)
        }
        
        self.alarmSoundChoices.delegate = self
        self.alarmSoundChoices.dataSource = self
        
        // Input data into alarm sound choices data array
        //alarmSoundChoicesData = ["Alarm Buzzer","Police Siren","Doorbell","Ambulance","Horn Honk","Fire Alarm","None"]
      
        // Stepper properties
        stepper?.autorepeat = true
        stepper?.maximumValue = 15
        stepper?.minimumValue = 1
        
        // Makes snooze value an integer, not double
        let stepperVal:Int = lround(self.stepper!.value)
        self.stepperValue.text = "\(stepperVal)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSound()
        //persistData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("Lit")
        alarmSoundChoices.selectRow(Sounds.sharedInstance.alarmRow, inComponent: 0, animated: true)
    
        /*
        stopSound() // optional?
        
        print("\(userDefaults.double(forKey: "Radius"))")
        radius.text = "\(userDefaults.double(forKey: "Radius"))"
        alarmSoundChoices.reloadAllComponents()
        alarmSoundChoices.selectRow(0, inComponent: 0, animated: true)
        // alarmSound = alarmBuzzerPlayer
        volumeSlider.value = 0.5
        vibrationSlider?.value = 0.5
        stepperValue.text = "5"
        stepper?.value = 5 */
    }
    
    @IBAction func beginEditRadius(_ sender: UITextField) {
        stopSound()
    }
    
    @IBAction func changeRadius(_ sender: UITextField) {
        var radiusStrToDouble: Double
        
        // If user enters an invalid radius or deletes everything in textfield, textfield is erased and radius value set to 0
        if Double(sender.text!) == nil {
            sender.text = nil
            radiusStrToDouble = 0
        }
        
        else {
            radiusStrToDouble = Double(sender.text!)!
        }
        
        radiusValue = radiusStrToDouble
    }
    
    @IBAction func slideVolume(_ sender: UISlider) {
        Sounds.sharedInstance.alarmSound.volume = volumeSlider.value
    }
    
    // TODO: Change so that phone vibrates increasingly with slider, not just vibrates once
    @IBAction func setVibration(_ sender: UISlider) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    // Change stepper label every time stepper is clicked
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        stopSound()
        let stepperVal:Int = lround(self.stepper!.value)
        self.stepperValue.text = "\(stepperVal)"
    }
    
    @IBAction func resetClicked(_ sender: UIButton) {
        stopSound()
        
        radius.text = "\(Settings.sharedInstance.radius)"
        //radius.text = "5.0"
        //radiusValue = 5.0
        alarmSoundChoices.reloadAllComponents()
        alarmSoundChoices.selectRow(0, inComponent: 0, animated: true)
        Sounds.sharedInstance.alarmSound = Sounds.sharedInstance.alarmBuzzerPlayer
        volumeSlider.value = 0.5
        vibrationSlider?.value = 0.5
        stepperValue.text = "5"
        stepper?.value = 5
    }
    
    func playChosenSound(chosenSound: AVAudioPlayer, numLoops: Int) {
        chosenSound.numberOfLoops = numLoops
        chosenSound.play()
    }
    
    func stopSound() {
        Sounds.sharedInstance.alarmBuzzerPlayer.stop()
        Sounds.sharedInstance.policeSirenPlayer.stop()
        Sounds.sharedInstance.doorbellPlayer.stop()
        Sounds.sharedInstance.ambulancePlayer.stop()
        Sounds.sharedInstance.hornHonkPlayer.stop()
        Sounds.sharedInstance.fireAlarmPlayer.stop()
    }
    
    // Number of columns of data in alarm sound picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Sounds.sharedInstance.alarmSoundChoicesData.count
    }
    
    // Data to return for row and component (column) that is being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Sounds.sharedInstance.alarmSoundChoicesData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            Sounds.sharedInstance.alarmSound = Sounds.sharedInstance.alarmBuzzerPlayer
            Sounds.sharedInstance.alarmRow = 0
        }
        
        else if row == 1 {
            Sounds.sharedInstance.alarmSound = Sounds.sharedInstance.policeSirenPlayer
            Sounds.sharedInstance.alarmSoundURL = Sounds.sharedInstance.policeSirenURL
            Sounds.sharedInstance.alarmRow = 1
        }
        
        else if row == 2 {
            Sounds.sharedInstance.alarmSound = Sounds.sharedInstance.doorbellPlayer
            Sounds.sharedInstance.alarmSoundURL = Sounds.sharedInstance.doorbellURL
            Sounds.sharedInstance.alarmRow = 2
        }
        
        else if row == 3 {
            Sounds.sharedInstance.alarmSound = Sounds.sharedInstance.ambulancePlayer
            Sounds.sharedInstance.alarmSoundURL = Sounds.sharedInstance.ambulanceURL
            Sounds.sharedInstance.alarmRow = 3
        }
        
        else if row == 4 {
            Sounds.sharedInstance.alarmSound = Sounds.sharedInstance.hornHonkPlayer
            Sounds.sharedInstance.alarmSoundURL = Sounds.sharedInstance.hornHonkURL
            Sounds.sharedInstance.alarmRow = 4
        }
            
        else if row == 5 {
            Sounds.sharedInstance.alarmSound = Sounds.sharedInstance.fireAlarmPlayer
            Sounds.sharedInstance.alarmSoundURL = Sounds.sharedInstance.fireAlarmURL
            Sounds.sharedInstance.alarmRow = 5
        }
        
        else if row == 6 {
            Sounds.sharedInstance.alarmRow = 6
        }
        
        stopSound()
        
        if row != 6 {
            playChosenSound(chosenSound: Sounds.sharedInstance.alarmSound, numLoops: 0)
        }
    }
    
    /*func persistData() {
        userDefaults.set(radiusValue, forKey: "Radius Value")
        // userDefaults.set(alarmSound, forKey: "Alarm Sound")
        userDefaults.set(volumeSlider.value, forKey: "Volume")
        userDefaults.set(vibrationSlider?.value, forKey: "Vibration Level")
        userDefaults.set(stepper?.value, forKey: "Snooze Timer")
        
        userDefaults.synchronize()
    }*/
}
