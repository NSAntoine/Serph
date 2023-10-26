//
//  Preferences.swift
//  Serph
//
//  Created by Serena on 24/10/2023.
//  

import Foundation

@propertyWrapper
struct Storage<Value> {
    let key: String
    let defaultValue: Value
    
    var wrappedValue: Value {
        get {
            return UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct CodableStorage<Value: Codable> {
    let key: String
    let defaultValue: Value
    
    var wrappedValue: Value {
        get {
            guard let data = UserDefaults.standard.data(forKey: key),
                  let decoded = try? JSONDecoder().decode(Value.self, from: data) else { return defaultValue }
            return decoded
        }
        
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

// Values here must always adhere to their IOKit ones
enum PowerSource: String, CaseIterable, Hashable {
    case ups = "UPS Power"
    case battery = "Battery Power"
    case acPower = "AC Power"
}

enum Preferences {
    @CodableStorage(key: "AppTriggers", defaultValue: [:])
    static var appTriggers: [ApplicationTrigger: PowerModeSetting]
    
    @Storage(key: "LastAuthorizedHelperHash", defaultValue: nil)
    static var lastAuthorizedHelperHash: String?
    
    @Storage(key: "PowerSource", defaultValue: PowerSource.battery.rawValue)
    static private var _powerSourceRaw: String
    
    static var powerSource: PowerSource {
        get {
            return PowerSource(rawValue: _powerSourceRaw) ?? .battery
        }
        
        set {
            _powerSourceRaw = newValue.rawValue
        }
    }
}
