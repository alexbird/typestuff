//
//  UserPreferences.swift
//  TypeStuff
//
//  Created by Alex Bird on 30/05/2026.
//

import SwiftUI
import Combine

/// Default typing speed in microseconds between characters (1000 = 1ms)
private let defaultTypingSpeed: Double = 15000

/// Manages user preferences for custom text strings
/// Persists 6 custom strings using UserDefaults and provides SwiftUI bindings
class UserPreferences: ObservableObject {
    private let defaults = UserDefaults.standard
    
    // Custom text strings for F7-F12 shortcuts
    @Published var customString1: String = "" {
        didSet { defaults.set(customString1, forKey: "customString1") }
    }
    @Published var customString2: String = "" {
        didSet { defaults.set(customString2, forKey: "customString2") }
    }
    @Published var customString3: String = "" {
        didSet { defaults.set(customString3, forKey: "customString3") }
    }
    @Published var customString4: String = "" {
        didSet { defaults.set(customString4, forKey: "customString4") }
    }
    @Published var customString5: String = "" {
        didSet { defaults.set(customString5, forKey: "customString5") }
    }
    @Published var customString6: String = "" {
        didSet { defaults.set(customString6, forKey: "customString6") }
    }
    
    // Press Enter after typing for each shortcut
    @Published var pressEnter1: Bool = false {
        didSet { defaults.set(pressEnter1, forKey: "pressEnter1") }
    }
    @Published var pressEnter2: Bool = false {
        didSet { defaults.set(pressEnter2, forKey: "pressEnter2") }
    }
    @Published var pressEnter3: Bool = false {
        didSet { defaults.set(pressEnter3, forKey: "pressEnter3") }
    }
    @Published var pressEnter4: Bool = false {
        didSet { defaults.set(pressEnter4, forKey: "pressEnter4") }
    }
    @Published var pressEnter5: Bool = false {
        didSet { defaults.set(pressEnter5, forKey: "pressEnter5") }
    }
    @Published var pressEnter6: Bool = false {
        didSet { defaults.set(pressEnter6, forKey: "pressEnter6") }
    }
    
    /// Typing speed in microseconds between characters (1000 = 1ms)
    /// Range: 500 (fastest) to 50000 (slowest), default 15000 (15ms)
    @Published var typingSpeed: Double = defaultTypingSpeed {
        didSet { defaults.set(typingSpeed, forKey: "typingSpeed") }
    }
    
    init() {
        // Load saved values from UserDefaults
        customString1 = defaults.string(forKey: "customString1") ?? ""
        customString2 = defaults.string(forKey: "customString2") ?? ""
        customString3 = defaults.string(forKey: "customString3") ?? ""
        customString4 = defaults.string(forKey: "customString4") ?? ""
        customString5 = defaults.string(forKey: "customString5") ?? ""
        customString6 = defaults.string(forKey: "customString6") ?? ""
        typingSpeed = defaults.double(forKey: "typingSpeed") != 0 ? defaults.double(forKey: "typingSpeed") : defaultTypingSpeed
        pressEnter1 = defaults.bool(forKey: "pressEnter1")
        pressEnter2 = defaults.bool(forKey: "pressEnter2")
        pressEnter3 = defaults.bool(forKey: "pressEnter3")
        pressEnter4 = defaults.bool(forKey: "pressEnter4")
        pressEnter5 = defaults.bool(forKey: "pressEnter5")
        pressEnter6 = defaults.bool(forKey: "pressEnter6")
    }
    
    /// Returns array of all custom strings for easy iteration
    var allStrings: [String] {
        [customString1, customString2, customString3, customString4, customString5, customString6]
    }
    
    /// Returns array of all pressEnter settings for easy iteration
    var allPressEnter: [Bool] {
        [pressEnter1, pressEnter2, pressEnter3, pressEnter4, pressEnter5, pressEnter6]
    }
    
    /// Returns the custom string at the specified index (0-5)
    func getString(at index: Int) -> String {
        switch index {
        case 0: return customString1
        case 1: return customString2
        case 2: return customString3
        case 3: return customString4
        case 4: return customString5
        case 5: return customString6
        default: return ""
        }
    }
    
    /// Updates the custom string at the specified index (0-5)
    func setString(_ value: String, at index: Int) {
        switch index {
        case 0: customString1 = value
        case 1: customString2 = value
        case 2: customString3 = value
        case 3: customString4 = value
        case 4: customString5 = value
        case 5: customString6 = value
        default: break
        }
    }
    
    /// Returns whether to press Enter after typing the string at the specified index (0-5)
    func getPressEnter(at index: Int) -> Bool {
        switch index {
        case 0: return pressEnter1
        case 1: return pressEnter2
        case 2: return pressEnter3
        case 3: return pressEnter4
        case 4: return pressEnter5
        case 5: return pressEnter6
        default: return false
        }
    }
}
