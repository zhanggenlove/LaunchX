//
//  LauncherXApp.swift
//  LauncherX
//
//  Created by zhanggen on 2025/10/20.
//

import KeyboardShortcuts
import SwiftUI

@main
struct LauncherXApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var model = LaunchpadModel.shared
    private var shortcutListener: Any?

    var body: some Scene {
        Settings { EmptyView() } // 不显示主窗口

            .commands {
                CommandGroup(replacing: .newItem) { }
                CommandGroup(replacing: .appInfo) { }
                CommandGroup(replacing: .appTermination) { }
                CommandGroup(replacing: .help) { }
                CommandGroup(replacing: .toolbar) { }
            }
    }
}

// AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    var model = LaunchpadModel.shared

    private var isShortcutPressed = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 添加 Status Bar 图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.title = "🔑"

        model.loadState()
        model.reloadApps()

        LaunchpadWindowManager.shared.show()

        setupShortcut()
    }

    func setupShortcut() {
        // 1️⃣ 全局监听（后台触发）
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleShortcut(event: event)
        }

        // 2️⃣ 本地监听（前台触发）
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleShortcut(event: event)
            return event
        }
    }

    private func handleShortcut(event: NSEvent) {
        // Option + Space
        if event.keyCode == 12 && event.modifierFlags.contains(.command) {
            LaunchpadWindowManager.shared.toggle()
        }
    }
}
