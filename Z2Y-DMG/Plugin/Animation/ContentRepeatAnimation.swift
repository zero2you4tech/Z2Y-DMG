//
//  ContentRepeatView.swift
//  Z2Y
//
//  Created by Oyjie on 2024/1/14.
//

import Foundation
import SwiftUI

public struct ContentRepeatAnimation: View {
    public var contents: [String] = [".", "..", "...", "....", ".....", "......"]
    @State private var currentIndex = 0
    public init(contents: [String] = [".", "..", "...", "....", ".....", "......"], currentIndex: Int = 0) {
        self.contents = contents
        self.currentIndex = currentIndex
    }
    
    public var body: some View {
        Text("\(contents[currentIndex])").onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                let nextIndex = self.currentIndex + 1
                if nextIndex >= self.contents.count {
                    self.currentIndex = 0
                } else {
                    self.currentIndex = nextIndex
                }
            }
        }
    }
}
