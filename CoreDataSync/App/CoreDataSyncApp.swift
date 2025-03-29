//
//  CoreDataSyncApp.swift
//  CoreDataSync
//

import SwiftUI
import UserNotifications
import CloudKit

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { success, error in
            assert(error == nil)
            assert(success)
            Task { @MainActor in
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        if CKNotification(fromRemoteNotificationDictionary: userInfo) != nil {
            _ = PersistenceController.shared.mirroringDelegate.perform(Selector(("applicationStateMonitorEnteredForeground:")), with: nil)
        }
        return .noData
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        if CKNotification(fromRemoteNotificationDictionary: response.notification.request.content.userInfo) != nil {
            _ = PersistenceController.shared.mirroringDelegate.perform(Selector(("applicationStateMonitorEnteredForeground:")), with: nil)
        }
    }
}

@main
struct CoreDataSyncApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
