//
//  Protocols.swift
//  Serph 
//
//  Created by Serena on 24/10/2023.
//

import Foundation

@objc public protocol SerphRootServicesProtocol {
    
    func setLowPowerModeStatus(status: PowerModeSetting, handler: @escaping (IOReturn) -> Void)
}
