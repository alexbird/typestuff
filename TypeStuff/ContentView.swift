//
//  ContentView.swift
//  TypeStuff
//
//  Created by Alex Bird on 30/05/2026.
//

import SwiftUI
import ApplicationServices

struct ContentView: View {
    @EnvironmentObject var preferences: UserPreferences
    @State private var hasAccessibilityPermission = false
    
    var body: some View {
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
                
                Divider()
                
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
        .frame(minWidth: 400, idealWidth: 500, maxWidth: .infinity,
               minHeight: 300, idealHeight: 500, maxHeight: .infinity)
        .onAppear {
            checkPermissions()
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
    ContentView()
        .environmentObject(UserPreferences())
}
