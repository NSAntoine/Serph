//
//  AppDelegate.swift
//  Serph
//
//  Created by Serena on 24/10/2023.
//  

import Cocoa
import class SwiftUI.NSHostingController
import CryptoKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    
    static func main() {
        let del = AppDelegate()
        NSApplication.shared.delegate = del
        NSApplication.shared.setActivationPolicy(.accessory)
        NSApplication.shared.run()
    }

    // Get the hash of the helper
    func helperHash() -> String {
        let helperPath = Bundle.main.bundleURL
            .appendingPathComponent("Contents")
            .appendingPathComponent("Library/LaunchServices/\(Constants.helperMachLabel)")
        let hash = SHA256.hash(data: try! Data(contentsOf: helperPath))
        
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        addStatusItem()
        
        let hash = helperHash()
        // SMJobBless asks for authorizatione everytime you call it
        // and you need to re-call it once the hash of the helper changes
        // so we compare it with the last authorized one and if it's not the same
        // (or if there is no hash in prefs)
        // prompt the user w SMJobBless
        if Preferences.lastAuthorizedHelperHash != hash {
            do {
                try BlessHelper.authorizeTool(Constants.helperMachLabel)
                print("got here")
                Preferences.lastAuthorizedHelperHash = hash
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
    }
    
    func addStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = .minusPlusBatteryblock
        
        statusItem.isVisible = true
        statusItem.behavior = .removalAllowed
        
        let menu = NSMenu()
        let prefsItem = menu.addItem(withTitle: "Preferences",
            action: #selector(openPreferences),
            keyEquivalent: "")
        
        menu.addItem(NSMenuItem.separator())
        
        let sourceItem = NSMenuItem(title: "Power Source", action: nil, keyEquivalent: "")
        sourceItem.submenu = powerSourceSubmenu()
        menu.addItem(sourceItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = .command
        
        prefsItem.target = self
        
        statusItem.menu = menu
    }
    
    func powerSourceSubmenu() -> NSMenu {
        let menu = NSMenu()
        
        for (index, source) in PowerSource.allCases.enumerated() {
            let item = NSMenuItem(title: source.rawValue, action: #selector(setPowerSource(sender:)), keyEquivalent: "")
            item.tag = index
            item.state = Preferences.powerSource == source ? .on : .off
            menu.addItem(item)
        }
        
        return menu
    }
    
    @objc
    func setPowerSource(sender: NSMenuItem) {
        let chosenSource = PowerSource.allCases[sender.tag]
        Preferences.powerSource = chosenSource
        
        for item in sender.menu?.items ?? [] {
            item.state = (item.tag == sender.tag) ? .on : .off
        }
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

