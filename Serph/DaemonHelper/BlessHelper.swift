//
//  BlessHelper.swift
//  Serph
//
//  Created by Serena on 24/10/2023.
//

import SecurityFoundation
import ServiceManagement

// SMJobBless helper
class BlessHelper {
    
    static func authorizeTool(_ name: String) throws {
        
        var auth: AuthorizationRef?
        let status: OSStatus = AuthorizationCreate(nil, nil, [], &auth)
        guard let auth, status == errAuthorizationSuccess else {
            throw BlessError("Failed to authorize helper tool.",
                             cause: "AuthorizationCreate returned \(status)")
        }
        
        var error: Unmanaged<CFError>?
        let blessReturn = SMJobBless(kSMDomainSystemLaunchd, name as CFString, auth, &error)
        guard blessReturn, error == nil else {
            throw BlessError("Failed to authorize helper tool.",
                             cause: "SMJobBless returned \(blessReturn), error = \(error?.takeUnretainedValue().localizedDescription ?? "None")")
        }
    }
    
    struct BlessError: Error, LocalizedError, CustomStringConvertible {
        let description: String
        let cause: String?
        
        init(_ description: String, cause: String? = nil) {
            self.description = description
            self.cause = cause
        }
        
        var errorDescription: String? { description }
    }
}
