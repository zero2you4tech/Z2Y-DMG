//
//  OverlayUnderline.swift
//  Z2Y
//
//  Created by Oyjie on 2023/11/13.
//

import Foundation
import SwiftUI

public struct OverlayUnderline: View {
    public var isShow: Bool = false
    public var borderColor: Color = .red
    public var borderWidth: CGFloat = 1
    public init(isShow: Bool = false, borderColor: Color = .red, borderWidth: CGFloat = 1) {
        self.isShow = isShow
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(.clear).frame(width: self.borderWidth)
            VStack(spacing: 0) {
                Rectangle().fill(.clear).frame(height: self.borderWidth)
                Spacer()
                Rectangle().fill(self.isShow ? self.borderColor : .clear).frame(height: self.borderWidth)
            }.allowsHitTesting(false) // 允许下方元素接收点击事件
            Rectangle().fill(.clear).frame(width: self.borderWidth)
        }
        .allowsHitTesting(false) // 允许下方元素接收点击事件
    }
    
    public func borderColor(_ borderColor: Color) -> Self {
        var copy = self
        copy.borderColor = borderColor
        return copy
    }
}
