//
//  SettingsViewController.swift
//  WakeMeAt
//
//  Created by Ivy Chenyao on 11/17/16.
//  Copyright © 2016 Ivy Chenyao. All rights reserved.
//

import UIKit
import AudioToolbox
import MediaPlayer
import AVFoundation // Has the code to allow us to use iPhone's speakers

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var volumeSlider: UISlider!
    
    // Snooze stepper
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var stepperValue: UILabel!

    // Alarm sound choices picker
    @IBOutlet weak var alarmSoundChoices: UIPickerView!
    
    // Alarm sound choices and path URLs
    var phoneRingingPlayer = AVAudioPlayer()
    var phoneRingingURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Home Phone Ringing-SoundBible.com-476855293", ofType: "mp3")!)
    
    var policeSirenPlayer = AVAudioPlayer()
    var policeSirenURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Siren-SoundBible.com-1094437108", ofType: "mp3")!)
    
    var doorbellPlayer = AVAudioPlayer()
    var doorbellURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Two Tone Doorbell-SoundBible.com-1238551671", ofType: "mp3")!)
    
    var ambulancePlayer = AVAudioPlayer()
    var ambulanceURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Fire Truck Siren-SoundBible.com-642727443", ofType: "mp3")!)
    
    var hornHonkPlayer = AVAudioPlayer()
    var hornHonkURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Traffic_Jam-Yo_Mama-1164700013-3", ofType: "mp3")!)
    
    var fireAlarmPlayer = AVAudioPlayer()
    var fireAlarmURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "gentex_cammander_3_code_3_horn-Brandon-938131891", ofType: "mp3")!)
    
    var alarmSoundChoicesData: [String] = [String]()
    
    var alarmSound = AVAudioPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loads alarm sound choices
        do {
            phoneRingingPlayer = try AVAudioPlayer(contentsOf: phoneRingingURL as URL)
        } catch let error {
            print(error.localizedDescription)
        }
        
        do {
            policeSirenPlayer = try AVAudioPlayer(contentsOf: policeSirenURL as URL)
        } catch let error {
            print(error.localizedDescription)
        }
        
        do {
            doorbellPlayer = try AVAudioPlayer(contentsOf: doorbellURL as URL)
        } catch let error {
            print(error.localizedDescription)
        }
        
        do {
            ambulancePlayer = try AVAudioPlayer(contentsOf: ambulanceURL as URL)
        } catch let error {
            print(error.localizedDescription)
        }
        
        do {
            hornHonkPlayer = try AVAudioPlayer(contentsOf: hornHonkURL as URL)
        } catch let error {
            print(error.localizedDescription)
        }
        
        do {
            fireAlarmPlayer = try AVAudioPlayer(contentsOf: fireAlarmURL as URL)
        } catch let error {
            print(error.localizedDescription)
        }
        
        self.alarmSound = phoneRingingPlayer
        self.title = "Settings"
        self.alarmSoundChoices.delegate = self
        self.alarmSoundChoices.dataSource = self
        
        // Input data into alarm sound choices data array
        alarmSoundChoicesData = ["Phone Ringing","Police Siren","Doorbell","Ambulance","Horn Honk","Fire Alarm","None"]
      
        // Stepper properties
        stepper.autorepeat = true
        stepper.maximumValue = 15
        stepper.minimumValue = 1
        
        // Makes snooze value integer, not double
        let stepperVal:Int = lround(self.stepper.value)
        self.stepperValue.text = "\(stepperVal)"
    }
    
    @IBAction func beginEditRadius(_ sender: UITextField) {
        stopSound()
    }
    
    // TODO: Change so that phone vibrates increasingly with slider, not just vibrates once
    @IBAction func setVibration(_ sender: UISlider) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    // Change stepper label every time stepper is clicked
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        stopSound()
        let stepperVal:Int = lround(self.stepper.value)
        self.stepperValue.text = "\(stepperVal)"
    }
    
    @IBAction func slideVolume(_ sender: UISlider) {
        alarmSound.volume = volumeSlider.value
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func playChosenSound(chosenSound: AVAudioPlayer, numLoops: Int) {
        chosenSound.numberOfLoops = numLoops // -1 Plays sound in never ending loop
        chosenSound.play()
    }
    
    func stopSound() {
        phoneRingingPlayer.stop()
        policeSirenPlayer.stop()
        doorbellPlayer.stop()
        ambulancePlayer.stop()
        hornHonkPlayer.stop()
        fireAlarmPlayer.stop()
    }
    
    // Number of columns of data in alarm sound picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return alarmSoundChoicesData.count
    }
    
    // Data to return for row and component (column) that is being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return alarmSoundChoicesData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row == 0 {
            alarmSound = phoneRingingPlayer
        }
        
        else if row == 1 {
            alarmSound = policeSirenPlayer
        }
        
        else if row == 2 {
            alarmSound = doorbellPlayer
        }
        
        else if row == 3 {
            alarmSound = ambulancePlayer
        }
        
        else if row == 4 {
            alarmSound = hornHonkPlayer
        }
            
        else if row == 5 {
            alarmSound = fireAlarmPlayer
        }
        
        stopSound()
        
        if row != 6 {
            playChosenSound(chosenSound: alarmSound, numLoops: 0)
        }
    }
    
    
    
}
