//
//  PreferencesView.swift
//  Serph
//
//  Created by Serena on 25/10/2023.
//  

import SwiftUI

struct PreferencesView: View {
    @State var appTriggers: [ApplicationTrigger: PowerModeSetting] = Preferences.appTriggers
    @State var sel: ApplicationTrigger? = nil
    
    var body: some View {
        Text("Serph")
            .font(.title.bold())
//        Text("Sera? Seraphita?")
//            .font(.caption)
//            .foregroundColor(.secondary)
            .padding(.bottom, -30)
        Spacer()
        if #available(macOS 13, *) {
            mainView
                .frame(width: 540, height: 320)
                .scrollContentBackground(.hidden)
        } else {
            mainView
                .frame(width: 540, height: 320)
        }
        Spacer()
    }
    
    @ViewBuilder
    var mainView: some View {
        VStack {
            HStack {
                Text("Application Triggers")
                    .foregroundColor(.secondary)
                    .bold()
                    .padding(.horizontal, 20)
                    .padding(.bottom, appTriggers.isEmpty ? 10 : 0)
                Spacer()
            }
            
            GroupBox {
                if appTriggers.isEmpty {
                        Text("No Application Triggers present, press the + button to change Low Power Mode status for when a chosen application is launched or closed.")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14).bold())
                        .padding(.horizontal, 50)
                        .frame(width: 500, height: 125)
                } else {
                    
                    List(Array(appTriggers), id: \.key, selection: $sel) { key, value in
                        AppTriggerCellView(trigger: key, modeSetting: value) { newMode in
                            Preferences.appTriggers[key] = newMode
                            withAnimation {
                                self.appTriggers = Preferences.appTriggers
                            }
                        } changedTrigger: { newTrigger in
                            if let val = Preferences.appTriggers.removeValue(forKey: key) {
                                Preferences.appTriggers[newTrigger] = val
                                withAnimation {
                                    self.appTriggers = Preferences.appTriggers
                                }
                            }
                        }
                            .tag(key)
                            .listRowBackground(Color.clear)
                    }

                }
                
                HStack {
                    HStack {
                        Button(action: {
                            let panel = NSOpenPanel()
                            panel.allowedContentTypes = [.application]
                            
                            if panel.runModal() == .OK,
                               let url = panel.url,
                               let bundle = Bundle(url: url),
                               let id = bundle.bundleIdentifier {
                                var trigger = ApplicationTrigger(applicationBundleID: id, kind: .open /* default value */)
                                
                                // same key already exists
                                if Preferences.appTriggers[trigger] != nil {
                                    trigger.kind = .closed
                                }
                                
                                Preferences.appTriggers[trigger] = .on // default value
                                withAnimation {
                                    self.appTriggers = Preferences.appTriggers
                                }
                            }
                            
                        }, label: {
                            Image(systemName: "plus")
                        })
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            if let sel {
                                Preferences.appTriggers.removeValue(forKey: sel)
                                withAnimation {
                                    self.appTriggers = Preferences.appTriggers
                                }
                                self.sel = nil
                            }
                        }, label: {
                            Image(systemName: "minus")
                        })
                        .buttonStyle(.plain)
                        .disabled(sel == nil)
                        .keyboardShortcut(.deleteForward)
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 0))
                    Spacer()
                }
            }
            .frame(width: 520, height: self.appTriggers.isEmpty ? 140 : 280)
        }
    }
}

struct AppTriggerCellView: View {
    @State var trigger: ApplicationTrigger
    @State var modeSetting: PowerModeSetting
    
    @State var name: String?
    @State var image: Image?
    
    var changedModeSetting: (PowerModeSetting) -> Void
    var changedTrigger: (ApplicationTrigger) -> Void
    
    var body: some View {
        HStack {
            image?
                .resizable()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                if let name {
                    Text(name)
                        .font(.title.weight(.semibold))
                }
                Text(trigger.applicationBundleID)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            GroupBox {
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Text("When")
                        Picker("", selection: $trigger.kind) {
                            ForEach(ApplicationTrigger.TriggerKind.allCases, id: \.self) { kind in
                                Text(kind.settingDescription)
                                    .tag(kind)
                            }
                        }
                        .frame(width: 100)
                        .padding(.trailing, 10)
                        
                        Text("app")
                    }
                    
                    HStack(spacing: 0) {
                        Text("Turn LPM")
                        
                        Picker("", selection: $modeSetting) {
                            ForEach(PowerModeSetting.allCases, id: \.self) { kind in
                                Text(kind.settingDescription)
                                    .tag(kind)
                            }
                        }
                        .frame(width: modeSetting == .opposite ? 100 : 65)
                    }
                }
            }
            .shadow(radius: 15)
        }
        .onChange(of: modeSetting, perform: changedModeSetting)
        .onChange(of: trigger, perform: changedTrigger)
        
        .onAppear {
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: self.trigger.applicationBundleID) {
                print(url)
                self.name = Bundle(url: url)?.object(forInfoDictionaryKey: "CFBundleName") as? String
                self.image = Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
            }
        }
        
        /*
        HStack {
            Picker("", selection: $modeSetting) {
                ForEach(PowerModeSetting.allCases, id: \.self) { setting in
                    Text(setting.settingDescription)
                        .tag(setting)
                }
            }
            .frame(width: modeSetting == .opposite ? 110 : 117)
            .onChange(of: self.modeSetting) { newValue in
                print(newValue)
            }
            
            Text("when app \(trigger.applicationBundleID) is ")
            Picker("", selection: $trigger.kind) {
                ForEach(ApplicationTrigger.TriggerKind.allCases, id: \.self) { setting in
                    Text(setting.settingDescription)
                        .tag(setting)
                }
            }
            .onChange(of: trigger.kind) { newValue in
                print(newValue)
            }
        }
         */
    }
}
