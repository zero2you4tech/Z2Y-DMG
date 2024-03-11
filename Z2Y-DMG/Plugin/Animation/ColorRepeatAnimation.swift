//
//  ColorRepeatAnimation.swift
//  Z2Y
//
//  Created by Oyjie on 2/6/24.
//

import Foundation
import SwiftUI

public struct ColorRepeatAnimation<Label>: View where Label: View {
    public var colors: [Color] = [.black, .blue, .orange, .red, .green]
    public let label: () -> Label
    
    @State private var currentIndex = 0
    
    public init(colors: [Color] = [.black, .blue, .orange, .red, .green], label: @escaping () -> Label, currentIndex: Int = 0) {
        self.colors = colors
        self.label = label
        self.currentIndex = currentIndex
    }
    
    public var body: some View {
        self.label().foregroundColor(colors[currentIndex]).onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                let nextIndex = self.currentIndex + 1
                if nextIndex >= self.colors.count {
                    self.currentIndex = 0
                } else {
                    self.currentIndex = nextIndex
                }
            }
        }
    }
}
