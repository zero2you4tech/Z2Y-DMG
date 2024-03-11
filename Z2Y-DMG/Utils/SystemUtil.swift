//
//  SystemUtil.swift
//  Z2Y-DMG
//
//  Created by Oyjie on 2/22/24.
//

import Foundation
import SwiftUI

public class SystemUtil {
    // 获取本地化的字符串 Localizable.strings
    public static func localizedString(_ key: String) -> String {
        return Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    }
    
    public static func createDmg(appURL: URL, dmgDirURL: URL) throws -> URL {
        let appName = appURL.lastPathComponent.dropLast(appURL.pathExtension.count)
        let dmgURL = dmgDirURL.appendingPathComponent("\(appName).dmg")
        // 使用 hdiutil 命令来创建 DMG 文件
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
        process.arguments = ["create", "-volname", "\(SystemUtil.localizedString("PleaseDrop")) \(appURL.lastPathComponent) \(SystemUtil.localizedString("to")) Applications \(SystemUtil.localizedString("Floder"))", "-srcfolder", appURL.deletingLastPathComponent().path, "-ov", "-format", "UDZO", dmgURL.path]
        try process.run()
        process.waitUntilExit()
        return dmgURL
    }
    
    // 运行内存
    public static func reportMemory() -> Double? {
        var taskInfo = task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMB = Double(taskInfo.resident_size) / 1024.0 / 1024.0
            return usedMB
        } else {
            print("Error with task_info(): \(String(cString: mach_error_string(kerr), encoding: .ascii) ?? "unknown error")")
            return nil
        }
    }
    
    // 应用名称
    public static func getAppName() -> String {
        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return appName
        } else {
            return "Z2Y Dmg Creator"
        }
    }
    // 当前App应用的图标
    public static func appIcon(size: CGFloat = 14) -> some View {
        Group {
            if let icon = NSImage(named: NSImage.applicationIconName) {
                Image(nsImage: icon).resizable().scaledToFit().frame(width: size, height: size)
            } else {
                Image(systemName: "pencil.and.outline")
                    .resizable().scaledToFit().frame(width: size, height: size)
            }
        }
    }
    
    // 添加状态栏图标
    public static func getStatusBar(target: AnyObject, action: Selector) -> NSStatusItem {
        let statusBar = NSStatusBar.system
        let statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        if let image = NSImage(named: NSImage.applicationIconName) {
            image.size = NSSize(width: 22, height: 22)
            let iconWithBorder = NSImage(size: NSSize(width: 22, height: 22), flipped: false) { rect in
                // 绘制图标
                image.draw(in: rect)
                
                // 绘制边框
                NSColor.red.setStroke()
                let borderRect = NSRect(x: rect.minX + 0.25, y: rect.minY + 0.25, width: rect.width - 0.5, height: rect.height - 0.5)
                let path = NSBezierPath(roundedRect: borderRect, xRadius: 5, yRadius: 5)
                path.lineWidth = 0.5
                path.stroke()
                
                return true
            }
            statusBarItem.button?.image = iconWithBorder
        }
        statusBarItem.button?.target = target
        statusBarItem.button?.action = action
        return statusBarItem
    }
    
    // 禁用 新增窗口 菜单
    public static func forbiddenNewWindowMenu() {
        QueueUtil.mainAsync {
            // 在应用启动后禁用 "New Window" 菜单项
            if let newWindowMenuItem = NSApplication.shared.mainMenu?.item(withTitle: "File")?.submenu?.item(withTitle: "New Window") {
                newWindowMenuItem.isEnabled = false
            }
            // 在应用启动后禁用 "新建窗口" 菜单项
            if let newWindowMenuItem = NSApplication.shared.mainMenu?.item(withTitle: "文件")?.submenu?.item(withTitle: "新建窗口") {
                newWindowMenuItem.isEnabled = false
            }
        }
    }
}
