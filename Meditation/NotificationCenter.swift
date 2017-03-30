//
//  NotificationCenter.swift
//  Meditation
//
//  Created by Zach Strenfel on 3/29/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationCenter {
    
    private var authorized: Bool = false
    
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval = 3.0, repeats: Bool = false) {
        if authorized {
            let content = UNMutableNotificationContent()
            content.title = title
            content.sound = UNNotificationSound.default()
            content.body = body
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)
            let request = UNNotificationRequest.init(identifier: title, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request) { error in
                log.error(error)
            }
            log.debug("should send notification")
        }
    }
    
    func updateAuthorization(granted: Bool) {
        self.authorized = granted
    }
}
