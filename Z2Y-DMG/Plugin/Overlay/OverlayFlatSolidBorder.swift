//
//  OverlayFlatSolidBorder.swift
//  Z2Y
//
//  Created by Oyjie on 2023/10/25.
//

import Foundation
import SwiftUI

public struct OverlayFlatSolidBorder: View {
    public var borderColor: Color = .gray
    public var borderWidth: CGFloat = 1
    public var bgColor: Color = .clear
    public init(borderColor: Color = .gray, borderWidth: CGFloat = 1, bgColor: Color = .clear) {
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.bgColor = bgColor
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(borderColor).frame(width: borderWidth)
            VStack(spacing: 0) {
                Rectangle().fill(borderColor).frame(height: borderWidth)
                Spacer()
                Rectangle().fill(borderColor).frame(height: borderWidth)
            }.allowsHitTesting(false) // 允许下方元素接收点击事件
            Rectangle().fill(borderColor).frame(width: borderWidth)
        }
        .background(bgColor)
        .allowsHitTesting(false) // 允许下方元素接收点击事件
        
    }
}
