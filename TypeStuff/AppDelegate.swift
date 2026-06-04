//
//  AppDelegate.swift
//  TypeStuff
//
//  Created by Alex Bird on 30/05/2026.
//

import Cocoa
import SwiftUI

/// Main application delegate for menu bar app
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var menuBarManager: MenuBarManager!
    var hotkeyManager: HotkeyManager!
    var textPoster: TextPoster!
    var preferences: UserPreferences!
    
    // Settings window
    private var settingsWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMainMenu()
        print("AppDelegate: Application launched")
        
        // Set activation policy for menu bar app
        NSApp.setActivationPolicy(.accessory)
        print("AppDelegate: Activation policy set to accessory")
        
        // Initialize preferences
        preferences = UserPreferences()
        print("AppDelegate: Preferences initialized")
        
        // Initialize managers
        textPoster = TextPoster(preferences: preferences)
        hotkeyManager = HotkeyManager()
        menuBarManager = MenuBarManager()
        print("AppDelegate: Managers initialized")
        
        // Setup menu bar
        menuBarManager.setupMenuBar()
        print("AppDelegate: Menu bar setup complete")
        
        // Configure menu callbacks
        menuBarManager.onSelectString = { [weak self] index in
            self?.handleStringSelection(index: index)
        }
        
        menuBarManager.onSelectClipboard = { [weak self] in
            self?.handleClipboardSelection()
        }
        
        menuBarManager.onSelectSettings = { [weak self] in
            self?.showSettings()
        }
        
        // Register global hotkeys
        hotkeyManager.registerHotkeys(
            onClipboard: { [weak self] in
                self?.handleClipboardSelection()
            },
            onString: { [weak self] index in
                self?.handleStringSelection(index: index)
            }
        )
        
        // Check and request accessibility permissions
        checkAccessibilityPermissions()
        
        // Update menu with current preferences
        updateMenu()
        
        // Observe preference changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(preferencesChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    /// Check accessibility permissions and request if needed
    private func checkAccessibilityPermissions() {
        let hasPermission = textPoster.hasAccessibilityPermission()
        print("AppDelegate: Accessibility permission status: \(hasPermission)")
        
        if !hasPermission {
            // Only prompt once on first launch
            let hasPromptedBefore = UserDefaults.standard.bool(forKey: "HasPromptedForAccessibility")
            
            if !hasPromptedBefore {
                print("AppDelegate: First launch, requesting accessibility permission")
                textPoster.requestAccessibilityPermission()
                UserDefaults.standard.set(true, forKey: "HasPromptedForAccessibility")
            } else {
                print("AppDelegate: Permission still not granted, but already prompted before")
            }
        }
        
        // Update menu to show warning if needed
        updateMenu()
    }
    
    /// Handle custom string selection from menu or hotkey
    private func handleStringSelection(index: Int) {
        guard index >= 0 && index < 6 else { return }
        
        let text = preferences.getString(at: index)
        let pressEnter = preferences.getPressEnter(at: index)
        
        guard !text.isEmpty else {
            print("AppDelegate: String at index \(index) is empty, skipping")
            return
        }
        
        let textToPost = pressEnter ? text + "\n" : text
        if !textPoster.postText(textToPost) {
            // Permission denied - update menu to show warning
            updateMenu()
        }
    }
    
    /// Handle clipboard selection from menu or hotkey
    private func handleClipboardSelection() {
        if !textPoster.postClipboardText() {
            // Permission denied - update menu to show warning
            updateMenu()
        }
    }
    
    /// Show settings window
    private func showSettings() {
        if let window = settingsWindow {
            // Reuse existing window
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            // Create new settings window
            let settingsView = SettingsView()
                .environmentObject(preferences)
            
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            
            window.title = "TypeStuff Settings"
            window.contentView = NSHostingView(rootView: settingsView)
            window.center()
            window.setFrameAutosaveName("TypeStuffSettings")
            window.isReleasedWhenClosed = false
            window.level = .floating // Stay in front
            window.minSize = NSSize(width: 400, height: 300)
            
            settingsWindow = window
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    /// Update menu with current preferences and permission status
    @objc private func updateMenu() {
        let hasPermission = textPoster.hasAccessibilityPermission()
        menuBarManager.updateMenu(
            customStrings: preferences.allStrings,
            pressEnter: preferences.allPressEnter,
            hasPermission: hasPermission
        )
    }
    
    /// Handle preference changes
    @objc private func preferencesChanged() {
        updateMenu()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager.unregisterHotkeys()
    }
    
    /// Setup main menu with Edit menu for copy/paste support
    private func setupMainMenu() {
        let mainMenu = NSMenu()
        
        // App menu
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Quit TypeStuff", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)
        
        // Edit menu (enables copy/paste in text fields)
        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)
        
        NSApp.mainMenu = mainMenu
    }
}
