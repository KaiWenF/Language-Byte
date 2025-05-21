import XCTest
import UserNotifications
@testable import Language_Byte_Watch_App

class NotificationSystemTests: XCTestCase {
    var notificationManager: MockNotificationManager!
    
    override func setUp() {
        super.setUp()
        notificationManager = MockNotificationManager()
        // Clear any notification settings
        UserDefaults.standard.removeObject(forKey: "notifications_enabled")
        UserDefaults.standard.removeObject(forKey: "notification_time")
    }
    
    override func tearDown() {
        notificationManager = nil
        super.tearDown()
    }
    
    func testRequestAuthorizationSuccess() async {
        // Given
        notificationManager.authorizationStatus = .authorized
        
        // When
        let isAuthorized = await notificationManager.requestAuthorization()
        
        // Then
        XCTAssertTrue(notificationManager.requestAuthorizationCalled, "Request authorization method should be called")
        XCTAssertTrue(isAuthorized, "Authorization should succeed")
    }
    
    func testRequestAuthorizationDenied() async {
        // Given
        notificationManager.authorizationStatus = .denied
        
        // When
        let isAuthorized = await notificationManager.requestAuthorization()
        
        // Then
        XCTAssertTrue(notificationManager.requestAuthorizationCalled, "Request authorization method should be called")
        XCTAssertFalse(isAuthorized, "Authorization should fail when denied")
    }
    
    func testCheckAuthorizationStatus() async {
        // Given
        notificationManager.authorizationStatus = .authorized
        
        // When
        let status = await notificationManager.checkAuthorizationStatus()
        
        // Then
        XCTAssertEqual(status, .authorized, "Should return correct authorization status")
        
        // Test denied status
        notificationManager.authorizationStatus = .denied
        let deniedStatus = await notificationManager.checkAuthorizationStatus()
        XCTAssertEqual(deniedStatus, .denied, "Should return correct authorization status when denied")
    }
    
    func testScheduleDailyNotification() async {
        // Given
        notificationManager.authorizationStatus = .authorized
        let notificationTime = DateComponents(hour: 9, minute: 0)
        UserDefaults.standard.set(true, forKey: "notifications_enabled")
        
        // When
        await notificationManager.scheduleDailyNotification(at: notificationTime)
        
        // Then
        XCTAssertTrue(notificationManager.scheduleNotificationCalled, "Schedule notification method should be called")
        XCTAssertEqual(notificationManager.scheduledNotificationTime?.hour, notificationTime.hour, "Hour should match")
        XCTAssertEqual(notificationManager.scheduledNotificationTime?.minute, notificationTime.minute, "Minute should match")
    }
    
    func testScheduleNotificationWithDifferentTimes() async {
        // Test morning notification (9 AM)
        let morningTime = DateComponents(hour: 9, minute: 0)
        await notificationManager.scheduleDailyNotification(at: morningTime)
        XCTAssertEqual(notificationManager.scheduledNotificationTime?.hour, 9, "Morning hour should be 9")
        
        // Test afternoon notification (3 PM)
        let afternoonTime = DateComponents(hour: 15, minute: 0)
        await notificationManager.scheduleDailyNotification(at: afternoonTime)
        XCTAssertEqual(notificationManager.scheduledNotificationTime?.hour, 15, "Afternoon hour should be 15")
        
        // Test evening notification (8 PM)
        let eveningTime = DateComponents(hour: 20, minute: 30)
        await notificationManager.scheduleDailyNotification(at: eveningTime)
        XCTAssertEqual(notificationManager.scheduledNotificationTime?.hour, 20, "Evening hour should be 20")
        XCTAssertEqual(notificationManager.scheduledNotificationTime?.minute, 30, "Evening minute should be 30")
    }
    
    func testCancelAllNotifications() async {
        // Given
        notificationManager.hasScheduledNotifications = true
        
        // When
        await notificationManager.cancelAllNotifications()
        
        // Then
        XCTAssertTrue(notificationManager.cancelAllNotificationsCalled, "Cancel all notifications method should be called")
        XCTAssertFalse(notificationManager.hasScheduledNotifications, "All notifications should be canceled")
    }
    
    func testUserPreferencesIntegration() async {
        // Test default state - notifications disabled
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "notifications_enabled"), "Notifications should be disabled by default")
        
        // Enable notifications
        UserDefaults.standard.set(true, forKey: "notifications_enabled")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "notifications_enabled"), "Notifications should be enabled after setting")
        
        // Set notification time
        let testTime = DateComponents(hour: 10, minute: 15)
        let timeString = "10:15"
        UserDefaults.standard.set(timeString, forKey: "notification_time")
        
        // Verify notification is scheduled at the saved time
        await notificationManager.scheduleBasedOnUserPreferences()
        XCTAssertTrue(notificationManager.scheduleNotificationCalled, "Schedule should be called based on preferences")
        XCTAssertEqual(notificationManager.scheduledNotificationTime?.hour, testTime.hour, "Hour should match preference")
        XCTAssertEqual(notificationManager.scheduledNotificationTime?.minute, testTime.minute, "Minute should match preference")
        
        // Disable notifications
        UserDefaults.standard.set(false, forKey: "notifications_enabled")
        
        // Reset state for next test
        notificationManager.resetState()
        
        // Verify no notification is scheduled when disabled
        await notificationManager.scheduleBasedOnUserPreferences()
        XCTAssertFalse(notificationManager.scheduleNotificationCalled, "Schedule should not be called when disabled")
    }
}

// MARK: - Mock Classes

class MockNotificationManager {
    var requestAuthorizationCalled = false
    var scheduleNotificationCalled = false
    var cancelAllNotificationsCalled = false
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var scheduledNotificationTime: DateComponents?
    var hasScheduledNotifications = false
    
    func requestAuthorization() async -> Bool {
        requestAuthorizationCalled = true
        return authorizationStatus == .authorized
    }
    
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        return authorizationStatus
    }
    
    func scheduleDailyNotification(at time: DateComponents) async {
        scheduleNotificationCalled = true
        scheduledNotificationTime = time
        hasScheduledNotifications = true
    }
    
    func cancelAllNotifications() async {
        cancelAllNotificationsCalled = true
        hasScheduledNotifications = false
    }
    
    func scheduleBasedOnUserPreferences() async {
        if UserDefaults.standard.bool(forKey: "notifications_enabled") {
            let timeString = UserDefaults.standard.string(forKey: "notification_time") ?? "09:00"
            let components = timeString.split(separator: ":")
            if components.count == 2,
               let hour = Int(components[0]),
               let minute = Int(components[1]) {
                let time = DateComponents(hour: hour, minute: minute)
                await scheduleDailyNotification(at: time)
            }
        }
    }
    
    func resetState() {
        scheduleNotificationCalled = false
        cancelAllNotificationsCalled = false
        scheduledNotificationTime = nil
    }
} 