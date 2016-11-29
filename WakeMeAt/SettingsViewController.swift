//
//  SettingsViewController.swift
//  WakeMeAt
//
//  Created by Ivy Chenyao on 11/17/16.
//  Copyright © 2016 Ivy Chenyao. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Snooze stepper
    @IBOutlet weak var snoozeValue: UILabel!
    
    @IBOutlet weak var stepper: UIStepper!
    
    @IBAction func stepperValueChanged(sender: UIStepper) {
        snoozeValue.text = "\(Int(stepper.value))"
    }

    // Alarm sound choices picker
    @IBOutlet weak var alarmSoundChoices: UIPickerView!
    
    
    
    var alarmSoundChoicesData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"

        // Do any additional setup after loading the view.
        
        self.alarmSoundChoices.delegate = self
        self.alarmSoundChoices.dataSource = self
        
        // Input data into alarm sound choices data array
        alarmSoundChoicesData = ["Phone Ringing","Police Siren","Doorbell","Ambulance","Horn Honk",
                                 "People Screaming","None"]
        
        // Stepper properties
        //stepper.value = 5
        stepper.autorepeat = true
        stepper.maximumValue = 15
        stepper.minimumValue = 1
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return alarmSoundChoicesData.count
    }
    
    // Data to return for row and component (column) that's being passed in
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
