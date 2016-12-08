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

    var radius: Double! = 5.0
    var alarm = AVAudioPlayer()
    var volume: Float! = 0.5
    var vibration: Float! = 0.5
//    var snooze: Double! =

    
    
    // Reset values to default in Settings. Called from SettingsViewController
    func reset() {
        radius = 5.0
        // add all reset stuff here
        
    }
    
    // Get all data from Settings. Called from MainViewController and SettingsViewController
    func getSettingsData() -> [String: Any] {
        return ["radius": radius,
                "alarm": alarm,
                "volume": volume,
                "vibration": vibration]
    }
    
    
    
    
}
