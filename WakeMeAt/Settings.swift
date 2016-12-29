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
    var alarm = Sounds.sharedInstance.alarmBuzzerPlayer
    var volume: Float! = 0.5
    var vibration: Float! = 0.5
    
    // Reset values to default in Settings. Called from SettingsViewController
    func reset() {
        radius = UserDefaults.standard.double(forKey: "radius")
        Sounds.sharedInstance.alarmRow = UserDefaults.standard.integer(forKey: "alarm row")
        volume = UserDefaults.standard.float(forKey: "volume")
        vibration = UserDefaults.standard.float(forKey: "vibration")
    }
    
    // Get all data from Settings. Called from MainViewController and SettingsViewController
    func getSettingsData() -> [String: Any] {
        return ["radius": radius,
                "alarm": alarm,
                "volume": volume,
                "vibration": vibration]
    }
    
    func setDefaults() {
        UserDefaults.standard.set(true, forKey: "Settings did load")
        UserDefaults.standard.set(radius, forKey: "radius")
        UserDefaults.standard.set(Sounds.sharedInstance.alarmRow, forKey: "alarm row")
        UserDefaults.standard.set(volume, forKey: "volume")
        UserDefaults.standard.set(vibration, forKey: "vibration")
    }
}
