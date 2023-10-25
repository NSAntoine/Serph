//
//  ApplicationsTrigger.swift
//  Serph
//
//  Created by Serena on 25/10/2023.
//  

import Foundation

struct ApplicationTrigger: Codable, Hashable {
    enum TriggerKind: Int, Codable, CaseIterable {
        case open
        case closed
        
        var settingDescription: String {
            switch self {
            case .open:
                return "launching"
            case .closed:
                return "closing"
            }
        }
    }
    
    static func == (lhs: ApplicationTrigger, rhs: ApplicationTrigger) -> Bool {
        return lhs.applicationBundleID == rhs.applicationBundleID && lhs.kind == rhs.kind
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(applicationBundleID)
        hasher.combine(kind)
    }
    
    let applicationBundleID: String
    var kind: TriggerKind
}
