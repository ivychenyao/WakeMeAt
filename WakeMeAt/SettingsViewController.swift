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
    
    var policeSirenURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Siren-SoundBible.com-1094437108", ofType: "mp3")!)
    
    var policeSirenPlayer = AVAudioPlayer()

    @IBOutlet weak var volumeSlider: UISlider!
    
    // Snooze stepper
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var stepperValue: UILabel!

    // Alarm sound choices picker
    @IBOutlet weak var alarmSoundChoices: UIPickerView!
    
    var alarmSoundChoicesData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            policeSirenPlayer = try AVAudioPlayer(contentsOf: policeSirenURL as URL)
        } catch let error {
            print(error.localizedDescription)
        }

        
        self.title = "Settings"

        // Do any additional setup after loading the view.
        
        self.alarmSoundChoices.delegate = self
        self.alarmSoundChoices.dataSource = self
        
        // Input data into alarm sound choices data array
        alarmSoundChoicesData = ["Phone Ringing","Police Siren","Doorbell","Ambulance","Horn Honk",
                                 "Fire Alarm","None"]
        
        // Stepper properties
        //stepper.value = 5
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func slideVolume(_ sender: UISlider) {
        policeSirenPlayer.numberOfLoops = -1 // Plays sound in never ending loop
        policeSirenPlayer.play()
        
        policeSirenPlayer.volume = volumeSlider.value
        
        //let wrapperView = UIView(frame: CGRect(x: 30, y: 200, width: 260, height: 20))
        //self.view.backgroundColor = UIColor.clear
        //self.view.addSubview(wrapperView)
        
        //let volumeView = MPVolumeView(frame: wrapperView.bounds)
        //wrapperView.addSubview(volumeView)
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
