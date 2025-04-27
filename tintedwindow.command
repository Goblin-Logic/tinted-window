#!/usr/bin/env swift

import Cocoa

// ———————————————————————————————————————————
// 0. Minimize the Terminal window that launched us
// ———————————————————————————————————————————
let minimizeScript = """
tell application "Terminal"
  set miniaturized of front window to true
end tell
"""
if let ascr = NSAppleScript(source: minimizeScript) {
  _ = ascr.executeAndReturnError(nil)
}

// ———————————————————————————————————————————
// 1. Subclass NSWindow to handle keys
// ———————————————————————————————————————————
class OverlayWindow: NSWindow {
  override var canBecomeKey: Bool { true }

  override func keyDown(with event: NSEvent) {
    // Cmd-Q quits
    if event.modifierFlags.contains(.command),
       event.charactersIgnoringModifiers?.lowercased() == "q"
    {
      NSApp.terminate(nil)
    }

    // ↑/↓ adjust opacity by ±5%
    let upKey: UInt16 = 126, downKey: UInt16 = 125
    if event.keyCode == upKey || event.keyCode == downKey {
      let delta: CGFloat = (event.keyCode == upKey ? 0.05 : -0.05)
      let nextOpacity = min(max(self.alphaValue + delta, 0.05), 1.0)
      self.backgroundColor = self.backgroundColor!
                                 .withAlphaComponent(nextOpacity)
      self.alphaValue = nextOpacity
      return
    }

    super.keyDown(with: event)
  }
}

// ———————————————————————————————————————————
// 2. Create & show the overlay
// ———————————————————————————————————————————
let app = NSApplication.shared
app.setActivationPolicy(.regular)

let frame = NSRect(x: 100, y: 100, width: 600, height: 400)
let style: NSWindow.StyleMask = [.titled, .resizable, .miniaturizable, .fullSizeContentView]

let win = OverlayWindow(
  contentRect: frame,
  styleMask: style,
  backing: .buffered,
  defer: false
)

win.titleVisibility = .hidden
win.titlebarAppearsTransparent = true
win.level = .mainMenu + 1
win.backgroundColor = NSColor.black.withAlphaComponent(0.5)
win.isOpaque = false
win.hasShadow = false

win.makeKeyAndOrderFront(nil)
app.activate(ignoringOtherApps: true)
app.run()
