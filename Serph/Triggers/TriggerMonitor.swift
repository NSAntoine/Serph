//
//  TriggerMonitor.swift
//  Serph
//
//  Created by Serena on 24/10/2023.
//  

import Cocoa

protocol TriggerMonitor {
    func startMonitoring()
}

class ApplicationsTriggerMonitor: TriggerMonitor {
    static let shared = ApplicationsTriggerMonitor()
    
    func startMonitoring() {
        let workspace = NSWorkspace.shared
        
        workspace.notificationCenter.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: nil) { notif in
            guard let bundleID = notif.userInfo?["NSApplicationBundleIdentifier"] as? String else { return }
            self.workspaceAppStatusDidChange(bundleID: bundleID, kind: .open)
        }
        
        workspace.notificationCenter.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: nil) { notif in
            guard let bundleID = notif.userInfo?["NSApplicationBundleIdentifier"] as? String else { return }
            self.workspaceAppStatusDidChange(bundleID: bundleID, kind: .closed)
        }
    }
    
    // Called when an app is closed or opened
    func workspaceAppStatusDidChange(bundleID: String, kind: ApplicationTrigger.TriggerKind) {
        let prefs = Preferences.appTriggers
        
        let trigger = ApplicationTrigger(applicationBundleID: bundleID, kind: kind)
        
        if let fromPrefs = prefs[trigger] {
            for app in NSWorkspace.shared.runningApplications {
                if prefs.contains(where: { (key, value) in
                    if key.applicationBundleID != bundleID, key.applicationBundleID == app.bundleIdentifier {
                        return value != fromPrefs
                    }
                    return false
                }) { return }
            }
            
            Client.shared.setLowPowerModeStatus(status: fromPrefs) { ret in
                print(ret)
            }
        }
    }
}
