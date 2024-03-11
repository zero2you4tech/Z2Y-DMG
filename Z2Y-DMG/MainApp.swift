//
//  Z2Y_DMGApp.swift
//  Z2Y-DMG
//
//  Created by Oyjie on 2/22/24.
//

import SwiftUI

@main
struct MainApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {}
        }
    }
}
