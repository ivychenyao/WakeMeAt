//
//  Settings.swift
//  WakeMeAt
//
//  Created by Ivy Chenyao on 12/6/16.
//  Copyright © 2016 Ivy Chenyao. All rights reserved.
//

import Foundation
import MediaPlayer

class Settings {
    static let sharedInstance = Settings()
    
    var radius: Double! = 1.0
    var alarm = Sounds.sharedInstance.alarmBuzzerPlayer //AVAudioPlayer()
    var volume: Float! = 0.5
    var vibration: Float! = 0.5
    
    // Reset values to default in Settings. Called from SettingsViewController
    func reset() {
        radius = 1.0
        alarm = Sounds.sharedInstance.alarmBuzzerPlayer
        Sounds.sharedInstance.alarmRow = 0
        volume = 0.5
        vibration = 0.5
    }
    
    // Get all data from Settings. Called from MainViewController and SettingsViewController
    func getSettingsData() -> [String: Any] {
        return ["radius": radius,
                "alarm": alarm,
                "volume": volume,
                "vibration": vibration]
    }
    
    func setDefaults() {
        print("Setting user defaults is happening")
        UserDefaults.standard.set(true, forKey: "Settings did load")
        
        UserDefaults.standard.set(radius, forKey: "radius")
        //UserDefaults.standard.set(alarm, forKey: "alarm")
        UserDefaults.standard.set(volume, forKey: "volume")
        UserDefaults.standard.set(vibration, forKey: "vibration")
        UserDefaults.standard.set(Sounds.sharedInstance.alarmRow, forKey: "alarm row")
    }
}
