//
//  WindowController.swift
//  Serph
//
//  Created by Serena on 25/10/2023.
//  

import Cocoa
import class SwiftUI.NSHostingController
import Carbon

class WindowController: NSWindowController {
    enum Kind {
        case preferences
    }
    
    init(kind: Kind) {
        let window: NSWindow
        
        switch kind {
        case .preferences:
            window = NSWindow(contentViewController: NSHostingController(rootView: PreferencesView()))
            
            window.titlebarAppearsTransparent = true
            window.title = "Preferences"
            window.titleVisibility = .hidden
            window.backgroundColor = .solidWindowBackground
            
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            
            window.setFrame(NSRect(origin: .zero, size: CGSize(width: 540, height: 320)), display: true)
            window.center()
        }
        
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
