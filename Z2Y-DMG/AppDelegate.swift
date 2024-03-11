//
//  AppDelegate.swift
//  Z2Y-DMG
//
//  Created by Oyjie on 2/22/24.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    // 状态栏按钮
    var statusBarItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.delegate = self
        }
        // 添加状态栏菜单
        self.statusBarItem = SystemUtil.getStatusBar(target: self, action: #selector(statusBarIconClicked))
        // 禁用新增窗口
        SystemUtil.forbiddenNewWindowMenu()
    }
    
    @objc func statusBarIconClicked() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // 在用户点击程序坞图标时激活应用的窗口
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.windows.first?.makeKeyAndOrderFront(nil)
        return true
    }
    
//    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
//        return true
//    }
    
    // 窗口尺寸设置
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        return NSSize(width: 500, height: 500)
    }
    
    func windowWillClose(_ notification: Notification) {
        // 在窗口关闭时改变应用的 activationPolicy
        NSApp.setActivationPolicy(.accessory)
    }
}
