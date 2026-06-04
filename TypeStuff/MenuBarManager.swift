//
//  MenuBarManager.swift
//  TypeStuff
//
//  Created by Alex Bird on 30/05/2026.
//

import Cocoa

/// Manages the menu bar status item and menu
class MenuBarManager {
    
    // Callbacks for menu actions
    var onSelectString: ((Int) -> Void)?
    var onSelectClipboard: (() -> Void)?
    var onSelectSettings: (() -> Void)?
    var onCheckPermissions: (() -> Bool)?
    
    private var statusItem: NSStatusItem?
    private var menu: NSMenu?
    
    // Tag constants for menu items
    private enum MenuTag: Int {
        case permissionWarning = 100
        case string1 = 1
        case string2 = 2
        case string3 = 3
        case string4 = 4
        case string5 = 5
        case string6 = 6
        case clipboard = 10
        case settings = 20
        case quit = 30
    }
    
    /// Create and configure the menu bar status item
    func setupMenuBar() {
        // Create status item with custom icon from icon.svg
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        print("MenuBarManager: Status item created: \(statusItem != nil)")
        
        if let button = statusItem?.button {
            // Try to load custom icon from bundle, fall back to SF Symbol
            if let iconURL = Bundle.main.url(forResource: "menubar", withExtension: "svg"),
               let image = NSImage(contentsOf: iconURL) {
                // Resize for menu bar (typically 18pt height)
                let menuBarHeight: CGFloat = 18
                let aspectRatio = image.size.width / image.size.height
                let resizedImage = NSImage(size: NSSize(width: menuBarHeight * aspectRatio, height: menuBarHeight))
                resizedImage.lockFocus()
                image.draw(in: NSRect(x: 0, y: 0, width: menuBarHeight * aspectRatio, height: menuBarHeight))
                resizedImage.unlockFocus()
                resizedImage.isTemplate = true
                button.image = resizedImage
                print("MenuBarManager: Loaded custom 'icon.svg'")
            } else if let image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "TypeStuff") {
                button.image = image
                button.image?.isTemplate = true
                print("MenuBarManager: Loaded 'keyboard' fallback icon")
            } else {
                // Last resort: text-based icon
                button.title = "TS"
                print("MenuBarManager: Using text fallback 'TS'")
            }
        } else {
            print("MenuBarManager: WARNING - Status item button is nil!")
        }
        
        // Build and attach menu
        buildMenu()
        print("MenuBarManager: Menu built and attached")
    }
    
    /// Build the menu structure
    func buildMenu(customStrings: [String] = ["", "", "", "", "", ""], pressEnter: [Bool] = [false, false, false, false, false, false], showPermissionWarning: Bool = false) {
        let newMenu = NSMenu()
        
        // Permission warning (if needed)
        if showPermissionWarning {
            let warningItem = NSMenuItem(title: "⚠️ Enable Accessibility", action: #selector(openSystemPreferences), keyEquivalent: "")
            warningItem.tag = MenuTag.permissionWarning.rawValue
            warningItem.target = self
            newMenu.addItem(warningItem)
            newMenu.addItem(NSMenuItem.separator())
        }
        
        // Clipboard option (⌥F6) - F6 = U+F709
        let f6Char = String(UnicodeScalar(0xF709)!)
        let clipboardItem = NSMenuItem(title: "Clipboard", action: #selector(clipboardSelected), keyEquivalent: f6Char)
        clipboardItem.keyEquivalentModifierMask = .option
        clipboardItem.tag = MenuTag.clipboard.rawValue
        clipboardItem.target = self
        clipboardItem.toolTip = "Paste clipboard text (up to 1000 chars)"
        newMenu.addItem(clipboardItem)
        
        newMenu.addItem(NSMenuItem.separator())
        
        // Custom strings (⌥F7-F12)
        // F-key Unicode characters: F7=U+F70A, F8=U+F70B, F9=U+F70C, F10=U+F70D, F11=U+F70E, F12=U+F70F
        for (index, string) in customStrings.enumerated() {
            let enterSuffix = (index < pressEnter.count && pressEnter[index]) ? " ⏎" : ""
            let displayText = string.isEmpty ? "(empty)" : string
            let truncatedText = truncateString(displayText, maxLength: 40) + enterSuffix
            
            // F7 starts at U+F70A
            let fKeyChar = String(UnicodeScalar(0xF70A + index)!)
            let item = NSMenuItem(title: truncatedText, action: #selector(stringSelected(_:)), keyEquivalent: fKeyChar)
            item.keyEquivalentModifierMask = .option
            item.tag = index + 1 // Tags 1-6 for strings 0-5
            item.target = self
            item.isEnabled = !string.isEmpty
            item.toolTip = string.isEmpty ? "Set in Settings" : string
            
            // Gray out "(empty)" text
            if string.isEmpty {
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: NSColor.secondaryLabelColor
                ]
                item.attributedTitle = NSAttributedString(string: truncatedText, attributes: attributes)
            }
            
            newMenu.addItem(item)
        }
        
        newMenu.addItem(NSMenuItem.separator())
        
        // Settings
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(settingsSelected), keyEquivalent: "")
        settingsItem.tag = MenuTag.settings.rawValue
        settingsItem.target = self
        newMenu.addItem(settingsItem)
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit TypeStuff", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.tag = MenuTag.quit.rawValue
        newMenu.addItem(quitItem)
        
        // Assign menu to status item
        statusItem?.menu = newMenu
        self.menu = newMenu
    }
    
    /// Truncate string for menu display
    private func truncateString(_ string: String, maxLength: Int) -> String {
        if string.count <= maxLength {
            return string
        }
        let endIndex = string.index(string.startIndex, offsetBy: maxLength - 3)
        return String(string[..<endIndex]) + "..."
    }
    
    // MARK: - Menu Actions
    
    @objc private func stringSelected(_ sender: NSMenuItem) {
        let index = sender.tag - 1 // Convert tag (1-6) to index (0-5)
        onSelectString?(index)
    }
    
    @objc private func clipboardSelected() {
        onSelectClipboard?()
    }
    
    @objc private func settingsSelected() {
        onSelectSettings?()
    }
    
    @objc private func openSystemPreferences() {
        // Open System Preferences to Accessibility
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    /// Update menu with new custom strings and permission status
    func updateMenu(customStrings: [String], pressEnter: [Bool], hasPermission: Bool) {
        buildMenu(customStrings: customStrings, pressEnter: pressEnter, showPermissionWarning: !hasPermission)
    }
}
