//
//  Server.swift
//  Helper
//
//  Created by Serena on 24/10/2023.
//  

import Foundation

class Server: NSObject {
    static let shared = Server()
    
    var listener: NSXPCListener?
    
    func start() {
        listener = NSXPCListener(machServiceName: Constants.helperMachLabel)
        listener?.delegate = self
        listener?.resume()
    }
}

extension Server: NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        
        newConnection.exportedInterface = NSXPCInterface(with: SerphRootServicesProtocol.self)
        
        let exportedObject = SerphRootServices()
        newConnection.exportedObject = exportedObject
        
        newConnection.resume()
        
        return true
    }
}
