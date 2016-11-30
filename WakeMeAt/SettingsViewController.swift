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
    
    var alarmSoundChoicesData: [String] = [String]()
    
    var alarmSound = AVAudioPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            policeSirenPlayer = try AVAudioPlayer(contentsOf: policeSirenURL as URL)
        } catch let error {
            print(error.localizedDescription)
        }
        
        do {
            phoneRingingPlayer = try AVAudioPlayer(contentsOf: phoneRingingURL as URL)
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
    
    // TODO: Change so that phone vibrates increasingly with slider, not just vibrates once
    @IBAction func setVibration(_ sender: UISlider) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    // Change stepper label every time stepper is clicked
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let stepperVal:Int = lround(self.stepper.value)
        self.stepperValue.text = "\(stepperVal)"
    }
    
    @IBAction func slideVolume(_ sender: UISlider) {
        alarmSound.volume = volumeSlider.value
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func playChosenSound(chosenSound: AVAudioPlayer) {
        chosenSound.numberOfLoops = -1 // Plays sound in never ending loop
        chosenSound.play()
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
        
        playChosenSound(chosenSound: alarmSound)
    }
    
    
    
}
