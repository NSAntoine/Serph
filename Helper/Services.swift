//
//  Services.swift
//  Helper
//
//  Created by Serena on 24/10/2023.
//  

import Foundation
import IOKit.ps

class SerphRootServices: NSObject, SerphRootServicesProtocol {
    
    func setLowPowerModeStatus(status: PowerModeSetting, powerSource: String, handler: @escaping (IOReturn) -> Void) {
        var newValue: CFNumber
        switch status {
        case .on:
            newValue = true as CFNumber
        case .off:
            newValue = false as CFNumber
        case .opposite:
            // Get current value
            var current: Unmanaged<CFTypeRef>?
            IOPMCopyPMSetting("LowPowerMode" as CFString, powerSource as CFString, &current)
            if var current = current?.takeUnretainedValue() as? Bool {
                // flip the current value
                current.toggle()
                newValue = current as CFNumber
            } else {
                return handler(-1) // idk man lol
            }
        }
        
        // Here is where we actually set LPM to on/off btw
        let returnStatus = IOPMSetPMPreference("LowPowerMode" as CFString, newValue, powerSource as CFString)
        handler(returnStatus)
    }
}
