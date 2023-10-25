//
//  Constants.swift
//  Serph
//
//  Created by Serena on 24/10/2023.
//  

import Foundation

struct Constants {
    static let helperMachLabel = "com.serena.Serph.helper"
}

@objc
public enum PowerModeSetting: Int, Codable, CaseIterable {
    case on
    case off
    case opposite
    
    var settingDescription: String {
        switch self {
        case .on:
            return "on"
        case .off:
            return "off"
        case .opposite:
            return "opposite"
        }
    }
}
