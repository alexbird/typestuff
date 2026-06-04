//
//  TextPoster.swift
//  TypeStuff
//
//  Created by Alex Bird on 30/05/2026.
//

import Cocoa
import ApplicationServices

/// Posts keyboard events to the system using CoreGraphics
/// Simulates typing text into the currently focused application
class TextPoster {
    
    /// Maximum allowed clipboard text length
    static let maxClipboardLength = 1000
    
    /// Reference to user preferences for typing speed
    private let preferences: UserPreferences
    
    /// Key code mapping: Character -> (keyCode, needsShift)
    private static let keyCodeMap: [Character: (CGKeyCode, Bool)] = [
        "a": (0, false), "b": (11, false), "c": (8, false), "d": (2, false),
        "e": (14, false), "f": (3, false), "g": (5, false), "h": (4, false),
        "i": (34, false), "j": (38, false), "k": (40, false), "l": (37, false),
        "m": (46, false), "n": (45, false), "o": (31, false), "p": (35, false),
        "q": (12, false), "r": (15, false), "s": (1, false), "t": (17, false),
        "u": (32, false), "v": (9, false), "w": (13, false), "x": (7, false),
        "y": (16, false), "z": (6, false),
        "A": (0, true), "B": (11, true), "C": (8, true), "D": (2, true),
        "E": (14, true), "F": (3, true), "G": (5, true), "H": (4, true),
        "I": (34, true), "J": (38, true), "K": (40, true), "L": (37, true),
        "M": (46, true), "N": (45, true), "O": (31, true), "P": (35, true),
        "Q": (12, true), "R": (15, true), "S": (1, true), "T": (17, true),
        "U": (32, true), "V": (9, true), "W": (13, true), "X": (7, true),
        "Y": (16, true), "Z": (6, true),
        "0": (29, false), "1": (18, false), "2": (19, false), "3": (20, false),
        "4": (21, false), "5": (23, false), "6": (22, false), "7": (26, false),
        "8": (28, false), "9": (25, false),
        ")": (29, true), "!": (18, true), "@": (19, true), "#": (20, true),
        "$": (21, true), "%": (23, true), "^": (22, true), "&": (26, true),
        "*": (28, true), "(": (25, true),
        " ": (49, false), "\n": (36, false), "\t": (48, false),
        "-": (27, false), "=": (24, false), "[": (33, false), "]": (30, false),
        "\\": (42, false), ";": (41, false), "'": (39, false), ",": (43, false),
        ".": (47, false), "/": (44, false), "`": (50, false),
        "_": (27, true), "+": (24, true), "{": (33, true), "}": (30, true),
        "|": (42, true), ":": (41, true), "\"": (39, true), "<": (43, true),
        ">": (47, true), "?": (44, true), "~": (50, true)
    ]
    
    /// Shift key virtual key code
    private static let shiftKeyCode: CGKeyCode = 56
    
    /// Maximum time to wait for modifier keys to be released (in microseconds)
    private static let maxModifierWait: useconds_t = 2_000_000 // 2 seconds
    
    /// Interval between modifier key checks (in microseconds)
    private static let modifierCheckInterval: useconds_t = 10_000 // 10ms
    
    init(preferences: UserPreferences) {
        self.preferences = preferences
    }
    
    /// Check if the app has accessibility permissions
    func hasAccessibilityPermission() -> Bool {
        return AXIsProcessTrusted()
    }
    
    /// Request accessibility permissions from the user
    func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    /// Check if any modifier keys (Option, Fn, Command, Control) are currently pressed
    private func areModifiersPressed() -> Bool {
        let flags = CGEventSource.flagsState(.hidSystemState)
        let modifierMask: CGEventFlags = [.maskAlternate, .maskCommand, .maskControl, .maskSecondaryFn]
        return !flags.intersection(modifierMask).isEmpty
    }
    
    /// Wait for all modifier keys to be released before proceeding
    /// Returns true if modifiers were released, false if timed out
    private func waitForModifiersReleased() -> Bool {
        var waited: useconds_t = 0
        while areModifiersPressed() && waited < Self.maxModifierWait {
            usleep(Self.modifierCheckInterval)
            waited += Self.modifierCheckInterval
        }
        
        if areModifiersPressed() {
            print("TextPoster: Timed out waiting for modifier keys to be released")
            return false
        }
        return true
    }
    
    /// Type a single character using actual key codes
    private func typeCharacter(_ char: Character, source: CGEventSource?, delay: useconds_t) {
        if let (keyCode, needsShift) = Self.keyCodeMap[char] {
            // Press shift if needed
            if needsShift {
                if let shiftDown = CGEvent(keyboardEventSource: source, virtualKey: Self.shiftKeyCode, keyDown: true) {
                    shiftDown.flags = .maskShift
                    shiftDown.post(tap: .cghidEventTap)
                }
            }
            
            // Key down
            if let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true) {
                if needsShift { keyDown.flags = .maskShift }
                keyDown.post(tap: .cghidEventTap)
            }
            
            // Key up
            if let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) {
                if needsShift { keyUp.flags = .maskShift }
                keyUp.post(tap: .cghidEventTap)
            }
            
            // Release shift if needed
            if needsShift {
                if let shiftUp = CGEvent(keyboardEventSource: source, virtualKey: Self.shiftKeyCode, keyDown: false) {
                    shiftUp.post(tap: .cghidEventTap)
                }
            }
        } else {
            // Fallback for unmapped characters: use Unicode string approach
            if let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true) {
                var unicodeChar = [UniChar](String(char).utf16)
                keyDownEvent.keyboardSetUnicodeString(stringLength: unicodeChar.count, unicodeString: &unicodeChar)
                keyDownEvent.post(tap: .cghidEventTap)
            }
            
            if let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) {
                var unicodeChar = [UniChar](String(char).utf16)
                keyUpEvent.keyboardSetUnicodeString(stringLength: unicodeChar.count, unicodeString: &unicodeChar)
                keyUpEvent.post(tap: .cghidEventTap)
            }
        }
        
        usleep(delay)
    }
    
    /// Post text to the currently focused application by simulating keyboard events
    /// - Parameter text: The text string to type
    /// - Returns: true if successful, false if permission denied or error
    @discardableResult
    func postText(_ text: String) -> Bool {
        guard !text.isEmpty else { return true }
        guard hasAccessibilityPermission() else {
            print("TextPoster: Accessibility permission denied")
            return false
        }
        
        // Wait for modifier keys (Option, Fn, etc.) to be released
        guard waitForModifiersReleased() else {
            return false
        }
        
        let source = CGEventSource(stateID: .hidSystemState)
        let delay = useconds_t(preferences.typingSpeed)
        
        for char in text {
            typeCharacter(char, source: source, delay: delay)
        }
        
        return true
    }
    
    /// Post clipboard text to the currently focused application
    /// Only posts if clipboard contains text and is under maxClipboardLength characters
    /// - Returns: true if successful or clipboard invalid, false if permission denied
    @discardableResult
    func postClipboardText() -> Bool {
        guard hasAccessibilityPermission() else {
            print("TextPoster: Accessibility permission denied for clipboard")
            return false
        }
        
        let pasteboard = NSPasteboard.general
        
        // Check if clipboard contains text
        guard let clipboardText = pasteboard.string(forType: .string) else {
            print("TextPoster: Clipboard does not contain text")
            return true // Not an error, just nothing to do
        }
        
        // Check length constraint
        guard clipboardText.count <= Self.maxClipboardLength else {
            print("TextPoster: Clipboard text exceeds \(Self.maxClipboardLength) characters (\(clipboardText.count))")
            return true // Not an error, just don't post
        }
        
        return postText(clipboardText)
    }
}
