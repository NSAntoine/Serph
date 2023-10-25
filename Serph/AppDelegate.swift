//
//  AppDelegate.swift
//  Serph
//
//  Created by Serena on 24/10/2023.
//  

import Cocoa
import class SwiftUI.NSHostingController

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    
    static func main() {
        let del = AppDelegate()
        NSApplication.shared.delegate = del
        NSApplication.shared.setActivationPolicy(.accessory)
        NSApplication.shared.run()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if !Preferences.didAuthorizeLaunchAgentBefore {
            do {
                try BlessHelper.authorizeTool(Constants.helperMachLabel)
                print("got here")
                Preferences.didAuthorizeLaunchAgentBefore = true
            } catch {
                print("catch!")
                
                if let error = error as? BlessHelper.BlessError {
                    let alert = NSAlert()
                    alert.messageText = error.description
                    if let cause = error.cause { alert.informativeText = cause }
                    alert.runModal()
                } else {
                    let alert = NSAlert(error: error)
                    alert.runModal()
                }
                
                return
            }
        }
        
        ApplicationsTriggerMonitor.shared.startMonitoring()
        
        Client.shared.start()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = .minusPlusBatteryblock
        
        statusItem.isVisible = true
        statusItem.behavior = .removalAllowed
        
        let menu = NSMenu()
        let prefsItem = menu.addItem(withTitle: "Preferences",
            action: #selector(openPreferences),
            keyEquivalent: "")
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = .command
        
        prefsItem.target = self
        
        statusItem.menu = menu
    }

    @objc
    func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc
    func openPreferences() {
        // if there's an existing preferences window, order it front.
        if let window = NSApplication.shared.windows.first(where: { $0.contentViewController is NSHostingController<PreferencesView> }) {
            window.orderFrontRegardless()
            return
        }
        
        let ctrller = WindowController(kind: .preferences)
        ctrller.showWindow(nil)
        ctrller.window?.orderFrontRegardless() // need this so it appears properly
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

