//
//  HoverClickText.swift
//  Z2Y
//
//  Created by Oyjie on 2023/11/13.
//

import SwiftUI
import AppKit

public struct HoverClickUnderlineBtn<Label>: View where Label : View {
    public var label: () -> Label
    public var onClick: () -> Void
    
    public var unlineColor: Color = .clear
    public var hoverUnlineColor: Color = .blue
    public var fgColor: Color = .black
    public var hoverFgColor: Color = .blue
    
    public init(label: @escaping () -> Label, onClick: @escaping () -> Void) {
        self.label = label
        self.onClick = onClick
    }
    
    @State public var isHovering: Bool = false
    public var body: some View {
        self.label().onHover { hovering in
            self.isHovering = hovering
        }.onTapGesture {
            self.onClick()
        }
        
        .foregroundColor(self.isHovering ? self.hoverFgColor : self.fgColor)
        .overlay(
            OverlayUnderline(isShow: true)
                .borderColor(self.isHovering ? self.hoverUnlineColor : self.unlineColor)
        )
    }
    
    public func unlineColor(_ unlineColor: Color) -> Self {
        var copy = self
        copy.unlineColor = unlineColor
        return copy
    }
    public func hoverUnlineColor(_ hoverUnlineColor: Color) -> Self {
        var copy = self
        copy.hoverUnlineColor = hoverUnlineColor
        return copy
    }
    public func fgColor(_ fgColor: Color) -> Self {
        var copy = self
        copy.fgColor = fgColor
        return copy
    }
    public func hoverFgColor(_ hoverFgColor: Color) -> Self {
        var copy = self
        copy.hoverFgColor = hoverFgColor
        return copy
    }
}
