//
//  WindowManager.swift
//  LauncherX
//
//  Created by zhanggen on 2025/10/27.
//

import Cocoa
import SwiftUI
import KeyboardShortcuts

final class LaunchpadWindowManager {
    static let shared = LaunchpadWindowManager()
    private var window: NSWindow!
    
    private var pannelShow: Bool = false

    func show() {
        guard window == nil else {
            pannelShow = true
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        guard let screen = NSScreen.main else { return }
        let screenRect = screen.frame

        // 1️⃣ 创建无边框、透明的窗口
        window = InteractiveFullscreenWindow(
            contentRect: screenRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        // 2️⃣ 设置窗口为完全无边框、透明、不可交互移动
        window.level = .modalPanel      // ✅ 让它盖过菜单栏和 Dock   screenSaver
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = false

        // 3️⃣ 让窗口出现在所有空间（Spaces）中
        window.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]

        // 4️⃣ 禁用系统菜单栏和 Dock
        NSApp.setActivationPolicy(.accessory)
        NSApp.activate(ignoringOtherApps: true)

        // 5️⃣ 添加 SwiftUI 内容
        let model = LaunchpadModel.shared
        let contentView = LaunchpadRootView()
            .frame(width: screenRect.width, height: screenRect.height)
            .environmentObject(model)

        let hostingController = NSHostingController(rootView: contentView)
        window.contentViewController = hostingController
        window.setFrame(screenRect, display: true)
        window.makeKeyAndOrderFront(nil)
        pannelShow = true
    }

    func hide() {
        pannelShow = false
        NSApplication.shared.keyWindow?.makeFirstResponder(nil)
        window?.orderOut(nil)
    }
    
    func toggle() {
        if pannelShow {
            hide()
        } else {
            show()
        }
    }

    // MARK: - 注册全局快捷键（例：⌘ + ⇧ + Space）
}



final class InteractiveFullscreenWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}


extension KeyboardShortcuts.Name {
    static let toggleUnicornMode = Self("toggleUnicornMode")
}
