//
//  OverlayRoundedSolidBorder.swift
//  Z2Y
//
//  Created by Oyjie on 2023/10/26.
//

import Foundation
import SwiftUI

public struct OverlayStrokeBorder: View {
    public var cornerRadius: CGFloat = 5
    public var bgColor: Color = .clear
    public var borderColor: Color = .gray
    public var borderWidth: CGFloat = 0.5
    
    
    public init(cornerRadius: CGFloat = 5, bgColor: Color = .clear, borderColor: Color = .gray, borderWidth: CGFloat = 0.5) {
        self.cornerRadius = cornerRadius
        self.bgColor = bgColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(borderColor, lineWidth: borderWidth) // 描边，比原来的稍微大点
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .allowsHitTesting(false) // 允许下方元素接收点击事件
    }
    
    public func bgColor(_ bgColor: Color) -> Self {
        var copy = self
        copy.bgColor = bgColor
        return copy
    }
    public func borderColor(_ borderColor: Color) -> Self {
        var copy = self
        copy.borderColor = borderColor
        return copy
    }
    public func borderWidth(_ borderWidth: CGFloat) -> Self {
        var copy = self
        copy.borderWidth = borderWidth
        return copy
    }
    public func cornerRadius(_ cornerRadius: CGFloat) -> Self {
        var copy = self
        copy.cornerRadius = cornerRadius
        return copy
    }
}
