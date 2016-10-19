//
//  InterfaceController.swift
//  alarm1 WatchKit Extension
//
//  Created by olderor on 16.10.16.
//  Copyright © 2016 olderor. All rights reserved.
//

import WatchKit
import Foundation


enum Time {
    case hours, minutes
}

extension Int {
    func toTimeString() -> String {
        if (self < 10) {
            return "0\(self)"
        }
        return "\(self)"
    }
}


class InterfaceController: WKInterfaceController, WKCrownDelegate {

    
    @IBOutlet var hoursButton: WKInterfaceButton!
    @IBOutlet var minutesButton: WKInterfaceButton!
    
    @IBOutlet var separatorLabel: WKInterfaceLabel!
    
    
    
    @IBOutlet var confirmButton: WKInterfaceButton!
    
    var currentMode: Time = .hours
    var currentModeEnabled: Bool = true
    var timer: Timer! = nil
    var alarmEnabled = false
    
    var minutes = 0 {
        didSet {
            minutesButton.setTitle(minutes.toTimeString())
        }
    }
    
    var hours = 0 {
        didSet {
            hoursButton.setTitle(hours.toTimeString())
        }
    }
    
    func timerTick() {
        if !alarmEnabled {
            let button = currentMode == .hours ? hoursButton : minutesButton
            //button?.setBackgroundColor(currentModeEnabled ? UIColor.black : UIColor.darkGray)
            button?.setAlpha(currentModeEnabled ? 1 : 0)
            currentModeEnabled = !currentModeEnabled
        }
    }
    
    func setTime() {
        let date = Date()
        let calendar = Calendar.current
        hours = (calendar as NSCalendar).component(.hour, from: date)
        minutes = (calendar as NSCalendar).component(.minute, from: date)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        crownSequencer.delegate = self
        crownSequencer.focus()
        
    }

    override func willActivate() {
        
        let ud = UserDefaults(suiteName: "com.olderor.alarm1")
        let value = ud?.value(forKey: "alarmEnabled") as? Bool
        if value != nil {
            alarmEnabled = value!
        }
        
        if alarmEnabled {
            let udHours = ud?.value(forKey: "hours") as? Int
            let udMinutes = ud?.value(forKey: "minutes") as? Int
            if udHours != nil && udMinutes != nil {
                hours = udHours!
                minutes = udMinutes!
            } else {
                setTime()
            }
        } else {
            setTime()
        }
        
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(InterfaceController.timerTick), userInfo: nil, repeats: true)
        }
        if alarmEnabled {
            confirmButton.setTitle("cancel alarm")
        } else {
            confirmButton.setTitle("confirm")
        }
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    @IBAction func onHoursTap() {
        if (currentMode == .hours) {
            return
        }
        currentMode = .hours
        if (currentModeEnabled) {
            minutesButton.setAlpha(1)
            currentModeEnabled = !currentModeEnabled
        }
    }
    
    @IBAction func onMinutesTap() {
        if (currentMode == .minutes) {
            return
        }
        currentMode = .minutes
        if (currentModeEnabled) {
            hoursButton.setAlpha(1)
            currentModeEnabled = !currentModeEnabled
        }
    }
    
    @IBAction func onConfirmTap() {
        
        alarmEnabled = !alarmEnabled
        if alarmEnabled {
            confirmButton.setTitle("cancel alarm")
        } else {
            confirmButton.setTitle("confirm")
        }
        
        let ud = UserDefaults(suiteName: "com.olderor.alarm1")
        ud?.set(alarmEnabled, forKey: "alarmEnabled")
        
        if alarmEnabled {
            ud?.set(hours, forKey: "hours")
            ud?.set(minutes, forKey: "minutes")
            
            let action = WKAlertAction(title: "OK", style: .default, handler: {})
            presentAlert(withTitle: "Done", message: "Alarm was set \nfor \(hours.toTimeString()):\(minutes.toTimeString())", preferredStyle: .alert, actions: [action])
        } else {
            setTime()
            
            let action = WKAlertAction(title: "OK", style: .default, handler: {})
            presentAlert(withTitle: "Done", message: "Alarm was\ndisabled", preferredStyle: .alert, actions: [action])
        }
    }
    
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        if rotationalDelta == 0 {
            return
        }
        
        if !alarmEnabled {
            let delta = rotationalDelta > 0 ? -1 : 1
            if (currentMode == .hours) {
                hours = (hours + delta + 24) % 24
            } else {
                minutes = (minutes + delta + 60) % 60
            }
        }
    }

}
