//
//  HotkeyManager.swift
//  TypeStuff
//
//  Created by Alex Bird on 30/05/2026.
//

import Carbon
import Foundation

/// Manages global keyboard shortcuts using Carbon framework
/// Maps F6 (clipboard) and F7-F12 (custom strings 0-5) to callbacks
class HotkeyManager {
    
    // F-key virtual key codes
    private enum FKey: UInt32 {
        case f6 = 0x61
        case f7 = 0x62
        case f8 = 0x64
        case f9 = 0x65
        case f10 = 0x6D
        case f11 = 0x67
        case f12 = 0x6F
    }
    
    // Hotkey identifiers for Carbon
    private enum HotkeyID: UInt32 {
        case clipboard = 1  // F6
        case string1 = 2    // F7
        case string2 = 3    // F8
        case string3 = 4    // F9
        case string4 = 5    // F10
        case string5 = 6    // F11
        case string6 = 7    // F12
    }
    
    // Callback types
    typealias ClipboardCallback = () -> Void
    typealias StringCallback = (Int) -> Void
    
    // Callbacks
    private var clipboardCallback: ClipboardCallback?
    private var stringCallback: StringCallback?
    
    // Registered hotkey references
    private var hotkeyRefs: [EventHotKeyRef?] = []
    
    // Event handler reference
    private var eventHandler: EventHandlerRef?
    
    /// Register global hotkeys with callbacks
    /// - Parameters:
    ///   - onClipboard: Called when F6 is pressed
    ///   - onString: Called when F7-F12 is pressed with index 0-5
    func registerHotkeys(onClipboard: @escaping ClipboardCallback, onString: @escaping StringCallback) {
        self.clipboardCallback = onClipboard
        self.stringCallback = onString
        
        // Install event handler
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(), { (_, inEvent, userData) -> OSStatus in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            
            var hotkeyID = EventHotKeyID()
            GetEventParameter(inEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                            nil, MemoryLayout<EventHotKeyID>.size, nil, &hotkeyID)
            
            manager.handleHotkey(id: hotkeyID.id)
            
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
        
        // Register individual hotkeys
        registerHotkey(id: .clipboard, keyCode: FKey.f6.rawValue)
        registerHotkey(id: .string1, keyCode: FKey.f7.rawValue)
        registerHotkey(id: .string2, keyCode: FKey.f8.rawValue)
        registerHotkey(id: .string3, keyCode: FKey.f9.rawValue)
        registerHotkey(id: .string4, keyCode: FKey.f10.rawValue)
        registerHotkey(id: .string5, keyCode: FKey.f11.rawValue)
        registerHotkey(id: .string6, keyCode: FKey.f12.rawValue)
    }
    
    /// Register a single hotkey
    private func registerHotkey(id: HotkeyID, keyCode: UInt32) {
        var hotkeyRef: EventHotKeyRef?
        let hotkeyID = EventHotKeyID(signature: OSType(0x54535446), id: id.rawValue) // 'TSTF' = TypeStuff
        
        // Option key modifier
        let optionKeyModifier: UInt32 = UInt32(optionKey)
        let status = RegisterEventHotKey(keyCode, optionKeyModifier, hotkeyID, GetApplicationEventTarget(), 0, &hotkeyRef)
        
        if status != noErr {
            print("HotkeyManager: Failed to register hotkey \(id) with key code \(keyCode), status: \(status)")
        } else {
            print("HotkeyManager: Registered hotkey \(id) with key code \(keyCode)")
        }
        
        hotkeyRefs.append(hotkeyRef)
    }
    
    /// Handle hotkey press event
    private func handleHotkey(id: UInt32) {
        guard let hotkeyID = HotkeyID(rawValue: id) else { return }
        
        switch hotkeyID {
        case .clipboard:
            clipboardCallback?()
        case .string1:
            stringCallback?(0)
        case .string2:
            stringCallback?(1)
        case .string3:
            stringCallback?(2)
        case .string4:
            stringCallback?(3)
        case .string5:
            stringCallback?(4)
        case .string6:
            stringCallback?(5)
        }
    }
    
    /// Unregister all hotkeys
    func unregisterHotkeys() {
        for hotkeyRef in hotkeyRefs {
            if let ref = hotkeyRef {
                UnregisterEventHotKey(ref)
            }
        }
        hotkeyRefs.removeAll()
        
        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }
    
    deinit {
        unregisterHotkeys()
    }
}
