//
//  DmgInfoObj.swift
//  Z2Y-DMG
//
//  Created by Oyjie on 2/22/24.
//

import Foundation
import SwiftUI
import AppDMG

class DmgInfoObj: ObservableObject {
    @Published var appPath: String = ""
    @Published var otherPaths: Set<String> = []
    @Published var appName: String = ""
    @Published var dmgFolderPath: String = ""
    @Published var tips: [String] = []
    @Published var status: DmgCreateStatus = .None
    var statusColor: Color {
        return self.status == .None ? .blue : self.status == .Success ? .green : self.status == .Fail ? .red : .gray
    }
    
    // 拖拽接收
    public func handleAppDrop(providers: [NSItemProvider]) -> Bool {
        
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (data, error) in
            if let error = error {
                print("Failed to load item: \(error)")
                return
            }
            
            if let urlData = data as? Data,
               let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                QueueUtil.mainAsync {
                    self.appPath = url.path
                    self.appName = url.lastPathComponent.replacingOccurrences(of: ".app", with: "")
                    print("App path: \(self.appPath)")
                    self.objectWillChange.send()
                }
            }
        }
        return true
    }

    // 点击接收
    public func handleAppTap() {
        QueueUtil.mainAsync {
            let openPanel = NSOpenPanel()
            openPanel.title = SystemUtil.localizedString("PleaseChooseAppFile")
            openPanel.message = SystemUtil.localizedString("PleaseChooseAppFile")
            // openPanel.allowedFileTypes = ["app"]
            openPanel.allowedContentTypes = [.application]
            openPanel.allowsMultipleSelection = false
            if openPanel.runModal() == .OK {
                self.appPath = openPanel.url?.path ?? ""
                self.appName = openPanel.url?.lastPathComponent.replacingOccurrences(of: ".app", with: "") ?? ""
                print("App path: \(self.appPath)")
                self.objectWillChange.send()
            }
        }
    }
    
    // 拖拽接收
    public func handleOtherDrops(providers: [NSItemProvider]) -> Bool {
        
        var otherPaths = self.otherPaths
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (data, error) in
                if let error = error {
                    print("Failed to load item: \(error)")
                    return
                }
                
                if let urlData = data as? Data,
                   let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                    otherPaths.insert(url.path)
                    
                }
            }
        }
        
        QueueUtil.mainAsync {
            self.otherPaths = otherPaths
            self.objectWillChange.send()
        }
        
        return true
    }
    
    // 移除文件
    public func removeOtherPath(_ otherPath: String) {
        QueueUtil.mainAsync {
            var otherPaths = self.otherPaths
            otherPaths.remove(otherPath)
            self.otherPaths = otherPaths
            self.objectWillChange.send()
        }
    }

    // 点击接收
    public func handleOtherTap() {
        QueueUtil.mainAsync {
            let openPanel = NSOpenPanel()
            openPanel.title = SystemUtil.localizedString("PleaseChooseOtherFile")
            openPanel.message = SystemUtil.localizedString("PleaseChooseOtherFile")
            // openPanel.allowedFileTypes = ["app"]
            // openPanel.allowedContentTypes = [.application]
            openPanel.allowsOtherFileTypes = true
            openPanel.allowsMultipleSelection = true
            if openPanel.runModal() == .OK {
                var otherPaths = self.otherPaths
                if let url = openPanel.url {
                    otherPaths.insert(url.path)
                }
                for url in openPanel.urls {
                    otherPaths.insert(url.path)
                }
                self.otherPaths = otherPaths
                self.objectWillChange.send()
                self.objectWillChange.send()
            }
        }
    }

    // 创建 DMG 文件
    public func handleCreateDMG() {
        QueueUtil.mainAsync {
            let openPanel = NSOpenPanel()
            openPanel.title = SystemUtil.localizedString("PleaseChooseSaveDmgDir")
            openPanel.message = SystemUtil.localizedString("PleaseChooseSaveDmgDir")
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.allowsMultipleSelection = false

            if openPanel.runModal() == .OK {
                self.dmgFolderPath = openPanel.url?.path ?? ""
                print("DMG folder path: \(self.dmgFolderPath)")
                self.createDMG(dmgFolderPath: self.dmgFolderPath, appPath: self.appPath)
            }
        }
    }
    
    public func addTip(_ tip: String, status: DmgCreateStatus? = nil) {
        QueueUtil.mainAsync {
            self.tips.append(tip)
            if let status = status {
                self.status = status
            }
            self.objectWillChange.send()
        }
    }
    
    // 创建 DMG 文件
    public func createDMG(dmgFolderPath: String, appPath: String, finshOpenDir: Bool = true) {
        QueueUtil.backendAsync {
            let fileManager = FileManager.default
            
            let dmgDirURL = URL(fileURLWithPath: dmgFolderPath)
            let tempDirURL = dmgDirURL.appendingPathComponent(UUID().uuidString)
            let tempAppURL = tempDirURL.appendingPathComponent("\(self.appName).app")
            // 组合文件（.app + /Applications)
            do {
                self.addTip("create temp dir...", status: .Running)
                // 创建最终放入 DMG 文件的文件夹
                try fileManager.createDirectory(atPath: dmgDirURL.path, withIntermediateDirectories: true, attributes: nil)
                // 创建 DMG 临时文件夹
                try fileManager.createDirectory(atPath: tempDirURL.path, withIntermediateDirectories: true, attributes: nil)
                // 将应用程序、其他文件和 /Applications 的快捷方式放入其中
                self.addTip("copy \(self.appPath)...", status: .Running)
                try fileManager.copyItem(atPath: appPath, toPath: tempAppURL.path)
                
                for otherFilePath in self.otherPaths {
                    self.addTip("copy \(otherFilePath)...", status: .Running)
                    try fileManager.copyItem(atPath: otherFilePath, toPath: tempDirURL.appendingPathComponent("\(URL(fileURLWithPath: otherFilePath).lastPathComponent)").path)
                }
                
                self.addTip("create /Applications link...", status: .Running)
                let applicationLinkPath = tempDirURL.appendingPathComponent("Applications").path
                try fileManager.createSymbolicLink(atPath: applicationLinkPath, withDestinationPath: "/Applications")
            } catch {
                print("Failed to setup DMG folder: \(error)")
                self.addTip("Failed to setup DMG folder: \(error)", status: .Fail)
                return
            }
            
            Task {
                // 打包成 .dmg 文件
                do {
                    self.addTip("hdiutil temp dir to \(self.appName).dmg...", status: .Running)
                    // 生成 dmg 文件
                    // let dmgURL = try SystemUtil.createDmg(tempDirURL: tempDirURL, dmgDirURL: dmgDirURL, appName: self.appName)
                    let dmgURL = try await AppDMG.default.createDMG(url: tempAppURL, to: dmgDirURL)
                    
                    // 删除临时文件夹，包含内部的文件
                    self.addTip("delete temp dir...", status: .Running)
                    try? FileManager.default.removeItem(at: tempDirURL)
                    
                    self.addTip("Success create \(self.appName).dmg!", status: .Success)
                    if finshOpenDir {
                        NSWorkspace.shared.open(dmgURL.deletingLastPathComponent())
                    }
                } catch {
                    print("Failed to create DMG file: \(error)")
                    self.addTip("Failed to create DMG file: \(error)", status: .Fail)
                }
                
                
            }
        }
    }
}

enum DmgCreateStatus: String {
    case None
    case Running
    case Fail
    case Success
}
