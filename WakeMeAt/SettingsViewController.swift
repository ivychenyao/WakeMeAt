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
            Sounds.sharedInstance.nonePlayer = try AVAudioPlayer(contentsOf: Sounds.sharedInstance.noneURL as URL)
        } catch let error {
            print(error.localizedDescription)
        }
        
        self.alarmSoundChoices.delegate = self
        self.alarmSoundChoices.dataSource = self
        
        // Stepper properties
        stepper?.autorepeat = true
        stepper?.maximumValue = 15
        stepper?.minimumValue = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSound()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        radius.text = "\(Settings.sharedInstance.radius!)"
        alarmSoundChoices.selectRow(Sounds.sharedInstance.alarmRow, inComponent: 0, animated: true)
        
        volumeSlider.value = Settings.sharedInstance.volume
        vibrationSlider?.value = Settings.sharedInstance.vibration
        stepperValue.text = "\(lround(Settings.sharedInstance.snooze!))"
        stepper?.value = (Settings.sharedInstance.snooze)
        
        stopSound() // optional?
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
        
        Settings.sharedInstance.radius = radiusStrToDouble
    }
    
    @IBAction func slideVolume(_ sender: UISlider) {
        Settings.sharedInstance.volume = volumeSlider.value
    }
    
    // TODO: Change so that phone vibrates increasingly with slider, not just vibrates once
    @IBAction func setVibration(_ sender: UISlider) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        Settings.sharedInstance.vibration = vibrationSlider?.value
    }
    
    // Change stepper label every time stepper is clicked
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        stopSound()
        Settings.sharedInstance.snooze = self.stepper!.value
        self.stepperValue.text = "\(lround(Settings.sharedInstance.snooze))"
    }
    
    @IBAction func resetClicked(_ sender: UIButton) {
        stopSound()
        Settings.sharedInstance.reset()

        radius.text = "\(Settings.sharedInstance.radius!)"
        alarmSoundChoices.selectRow(0, inComponent: 0, animated: true)
        volumeSlider.value = 0.5
        vibrationSlider?.value = 0.5
        stepperValue.text = "5"
        stepper?.value = 5.0
    }
    
    func playChosenSound(chosenSound: AVAudioPlayer, numLoops: Int) {
        chosenSound.numberOfLoops = numLoops
        chosenSound.volume = Settings.sharedInstance.volume
        chosenSound.play()
    }
    
    func stopSound() {
        Sounds.sharedInstance.alarmSound.stop()
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
            Sounds.sharedInstance.alarmSound = Sounds.sharedInstance.nonePlayer
            Sounds.sharedInstance.alarmSoundURL = Sounds.sharedInstance.noneURL
            Sounds.sharedInstance.alarmRow = 6
        }
        
        stopSound()
        
        playChosenSound(chosenSound: Sounds.sharedInstance.alarmSound, numLoops: 0)
        
    }
}
