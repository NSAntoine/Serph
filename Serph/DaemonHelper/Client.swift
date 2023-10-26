//
//  Client.swift
//  Serph
//
//  Created by Serena on 24/10/2023.
//  

import Foundation

class Client {
    
    static let shared = Client()
    
    var connection: NSXPCConnection?
    
    func start() {
        connection = NSXPCConnection(machServiceName: Constants.helperMachLabel, options: .privileged)
        
        connection?.remoteObjectInterface = NSXPCInterface(with: SerphRootServicesProtocol.self)
        
        connection?.activate()
    }
    
    func setLowPowerModeStatus(status: PowerModeSetting, handler: @escaping (IOReturn) -> Void) {
        print("Calling XPC")
        proxy()?.setLowPowerModeStatus(status: status, powerSource: Preferences.powerSource.rawValue, handler: handler)
    }
    
    func proxy() -> SerphRootServicesProtocol? {
        return connection?.remoteObjectProxy as? SerphRootServicesProtocol
    }
}
