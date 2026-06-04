//
//  SettingsView.swift
//  TypeStuff
//
//  Created by Alex Bird on 30/05/2026.
//

import SwiftUI
import ApplicationServices
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject var preferences: UserPreferences
    @State private var hasAccessibilityPermission = false
    @State private var launchAtLogin = false
    @Environment(\.appearsActive) private var appearsActive
    
    var body: some View {
        TabView {
            typingTab
                .tabItem {
                    Label("Typing", systemImage: "keyboard")
                }
            
            systemTab
                .tabItem {
                    Label("System", systemImage: "gearshape")
                }
        }
        .frame(minWidth: 400, idealWidth: 500, maxWidth: .infinity,
               minHeight: 300, idealHeight: 500, maxHeight: .infinity)
        .onAppear {
            checkPermissions()
            syncLaunchAtLoginState()
        }
        .onChange(of: appearsActive) { _, newValue in
            guard newValue else { return }
            syncLaunchAtLoginState()
        }
        .onChange(of: launchAtLogin) { _, newValue in
            if newValue {
                try? SMAppService.mainApp.register()
            } else {
                try? SMAppService.mainApp.unregister()
            }
        }
    }
    
    private func syncLaunchAtLoginState() {
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }
    
    private var typingTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Custom strings form
                VStack(alignment: .leading, spacing: 12) {
                    Text("Stuff to type")
                        .font(.headline)
                    
                    Text("⌥F6 is reserved for clipboard (up to 1000 characters)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    LabeledContent("⌥F7") {
                        HStack {
                            TextField("", text: $preferences.customString1)
                                .textFieldStyle(.roundedBorder)
                            Toggle("⏎", isOn: $preferences.pressEnter1)
                                .toggleStyle(.checkbox)
                                .help("Press Enter after typing")
                        }
                    }
                    
                    LabeledContent("⌥F8") {
                        HStack {
                            TextField("", text: $preferences.customString2)
                                .textFieldStyle(.roundedBorder)
                            Toggle("⏎", isOn: $preferences.pressEnter2)
                                .toggleStyle(.checkbox)
                                .help("Press Enter after typing")
                        }
                    }
                    
                    LabeledContent("⌥F9") {
                        HStack {
                            TextField("", text: $preferences.customString3)
                                .textFieldStyle(.roundedBorder)
                            Toggle("⏎", isOn: $preferences.pressEnter3)
                                .toggleStyle(.checkbox)
                                .help("Press Enter after typing")
                        }
                    }
                    
                    LabeledContent("⌥F10") {
                        HStack {
                            TextField("", text: $preferences.customString4)
                                .textFieldStyle(.roundedBorder)
                            Toggle("⏎", isOn: $preferences.pressEnter4)
                                .toggleStyle(.checkbox)
                                .help("Press Enter after typing")
                        }
                    }
                    
                    LabeledContent("⌥F11") {
                        HStack {
                            TextField("", text: $preferences.customString5)
                                .textFieldStyle(.roundedBorder)
                            Toggle("⏎", isOn: $preferences.pressEnter5)
                                .toggleStyle(.checkbox)
                                .help("Press Enter after typing")
                        }
                    }
                    
                    LabeledContent("⌥F12") {
                        HStack {
                            TextField("", text: $preferences.customString6)
                                .textFieldStyle(.roundedBorder)
                            Toggle("⏎", isOn: $preferences.pressEnter6)
                                .toggleStyle(.checkbox)
                                .help("Press Enter after typing")
                        }
                    }
                }
                
                Divider()
                
                // Typing speed setting
                VStack(alignment: .leading, spacing: 12) {
                    Text("Typing speed")
                        .font(.headline)
                    
                    HStack {
                        Text("Slow")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: Binding(
                            get: { 50500 - preferences.typingSpeed },
                            set: { preferences.typingSpeed = 50500 - $0 }
                        ), in: 500...50000, step: 500)
                        
                        Text("Fast")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Delay: \(String(format: "%.0f", preferences.typingSpeed / 1000))ms per character")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(24)
        }
    }
    
    private var systemTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Permission status
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: hasAccessibilityPermission ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(hasAccessibilityPermission ? .green : .orange)
                        
                        Text("Accessibility Permissions")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        if !hasAccessibilityPermission {
                            Button("Grant Access") {
                                openSystemPreferences()
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Text("Enabled")
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                    }
                    
                    Text("Required to send keyboard events to other applications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
                
                // Launch at login setting
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "power")
                            .foregroundColor(.secondary)
                        
                        Text("Launch at Login")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Toggle("", isOn: $launchAtLogin)
                            .toggleStyle(.switch)
                    }
                    
                    Text("Add TypeStuff to the menu bar automatically when you log in")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(24)
        }
    }
    
    private func checkPermissions() {
        hasAccessibilityPermission = AXIsProcessTrusted()
    }
    
    private func openSystemPreferences() {
        // Request permissions with prompt
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        // Recheck after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            checkPermissions()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserPreferences())
}
