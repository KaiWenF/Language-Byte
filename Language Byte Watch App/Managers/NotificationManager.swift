//
//
//  NotificationManager.swift
//  Language Byte Watch App
//
//  Created by [Kai Wen] on [02/10/2025].
//

import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    
    /// Request notification permission on the watch
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            } else {
                print("Permission granted? \(granted)")
            }
        }
    }
    
    /// Schedule a notification to fire daily at the specified hour and minute.
    /// Example: 9:00 AM each day.
    func scheduleDailyNotification(hour: Int, minute: Int) {
        // 1. Remove existing notifications with the same identifier, if necessary
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyWord"])
        
        // 2. Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Language Byte"
        content.body = "Tap to see today's new word!"
        content.sound = UNNotificationSound.default
        
        // 3. Create date components for the trigger time
        var dateComponents = DateComponents()
        dateComponents.hour = hour        // e.g. 9 for 9:00 AM
        dateComponents.minute = minute    // e.g. 0 for :00 minutes
        
        // 4. Create the trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // 5. Create the request
        let request = UNNotificationRequest(
            identifier: "dailyWord",
            content: content,
            trigger: trigger
        )
        
        // 6. Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Daily notification scheduled for \(hour):\(minute).")
            }
        }
    }
}
