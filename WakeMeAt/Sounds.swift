//
//  Sounds.swift
//  WakeMeAt
//
//  Created by Ivy Chenyao on 12/8/16.
//  Copyright © 2016 Ivy Chenyao. All rights reserved.
//

import Foundation
import AudioToolbox
import MediaPlayer

class Sounds {
    
    static let sharedInstance = Sounds()
    
    var alarmSound: AVAudioPlayer
    var alarmSoundURL: NSURL
    var alarmRow: Int
    
    // Alarm sound choices and path URLs
    var alarmBuzzerPlayer = AVAudioPlayer()
    var alarmBuzzerURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Alarm Buzzer", ofType: "mp3")!)
    
    var policeSirenPlayer = AVAudioPlayer()
    var policeSirenURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Police Siren", ofType: "mp3")!)
    
    var doorbellPlayer = AVAudioPlayer()
    var doorbellURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Doorbell", ofType: "mp3")!)
    
    var ambulancePlayer = AVAudioPlayer()
    var ambulanceURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Ambulance", ofType: "mp3")!)
    
    var hornHonkPlayer = AVAudioPlayer()
    var hornHonkURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Horn Honk", ofType: "mp3")!)
    
    var fireAlarmPlayer = AVAudioPlayer()
    var fireAlarmURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "Fire Alarm", ofType: "mp3")!)
    
    var alarmSoundChoicesData = ["Alarm Buzzer","Police Siren","Doorbell","Ambulance","Horn Honk","Fire Alarm","None"]
    
    init() {
        alarmSound = alarmBuzzerPlayer
        alarmSoundURL = alarmBuzzerURL
        alarmRow = 0
    }
    
    func getSoundsData() -> [String: AVAudioPlayer] {
        return ["Alarm Buzzer": alarmBuzzerPlayer,
                "Police Siren": policeSirenPlayer,
                "Doorbell": doorbellPlayer,
                "Ambulance": ambulancePlayer,
                "Horn Honk": hornHonkPlayer,
                "Fire Alarm": fireAlarmPlayer]
    }
}
