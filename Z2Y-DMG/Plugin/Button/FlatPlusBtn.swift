//
//  FlatPlusBtn.swift
//  Z2Y
//
//  Created by Oyjie on 2023/11/16.
//

import Foundation
import SwiftUI

public struct FlatPlusButton<Label>: View where Label: View {
    public let action: (() -> Void)?
    public let label: (Bool, Bool) -> Label
    public var isSelected: Bool = false
    
    private var width: CGFloat? = nil
    private var height: CGFloat? = nil

    private var borderColor: Color = .clear
    private var hoverBorderColor: Color = .red
    private var selectedBorderColor: Color = .clear
    
    private var borderWidth: CGFloat = 0.5
    private var hoverBorderWidth: CGFloat = 0.5
    private var selectedBorderWidth: CGFloat = 0.5
    
    private var bgColor: Color = .clear
    private var hoverBgColor: Color = .blue.opacity(0.5)
    private var clickBgColor: Color = .blue
    private var selectedBgColor: Color = .blue
    
    private var fgColor: Color = .black
    private var hoverFgColor: Color = .white
    private var clickFgColor: Color = .white
    private var selectedFgColor: Color = .white
    private var paddingWidth: CGFloat = 5
    
    // 需要扩展，给他加个容器用于额外视图渲染
    public init(action: @escaping () -> Void, isSelected: Bool = false,
         @ViewBuilder label: @escaping (_ hovering: Bool, _ clicking: Bool) -> Label) {
        self.action = action
        self.label = label
        self.isSelected = isSelected
    }
    
    @State private var hovering: Bool = false
    @State private var clicking: Bool = false
    public var body: some View {
        Button(action: {
            self.hovering = false
            self.clicking = true
            action?()
        }) {
            HStack(spacing: 5) {
                label(hovering, clicking)
            }.padding(paddingWidth).contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .onHover(perform: { hovering in
            self.hovering = hovering
            self.clicking = false
        })
        .accentColor(.clear).frame(width: width, height: height)
        .overlay(
            OverlayFlatSolidBorder(
                borderColor: hovering ? hoverBorderColor : isSelected ? selectedBorderColor : borderColor,
                borderWidth: hovering ? hoverBorderWidth : isSelected ? selectedBorderWidth : borderWidth
            )
        )
        .foregroundColor(clicking ? clickFgColor : hovering ? hoverFgColor : isSelected ? selectedFgColor :  fgColor)
        .background(Rectangle().fill(clicking ? clickBgColor : hovering ? hoverBgColor : isSelected ? selectedBgColor :  bgColor))
        .contentShape(Rectangle())
    }
    
    public func frameSize(_ width: CGFloat? = nil, _ height: CGFloat? = nil) -> Self {
        var copy = self
        copy.width = width
        copy.height = height
        return copy
    }

    public func color(bgColor: Color, fgColor: Color) -> Self {
        var copy = self
        copy.bgColor = bgColor
        copy.fgColor = fgColor
        return copy
    }
    
    public func hoverColor(bgColor: Color, fgColor: Color) -> Self {
        var copy = self
        copy.hoverBgColor = bgColor
        copy.hoverFgColor = fgColor
        return copy
    }
    
    public func clickColor(bgColor: Color, fgColor: Color) -> Self {
        var copy = self
        copy.clickBgColor = bgColor
        copy.clickFgColor = fgColor
        return copy
    }
    
    public func selectInfo(isSelected: Bool,
                    bgColor: Color = .blue, fgColor: Color = .white,
                    borderColor: Color = .gray, borderWidth: CGFloat = 0.5) -> Self {
        var copy = self
        copy.isSelected = isSelected
        copy.selectedBgColor = bgColor
        copy.selectedFgColor = fgColor
        copy.selectedBorderColor = borderColor
        copy.selectedBorderWidth = borderWidth
        return copy
    }
    
    public func borderColor(_ borderColor: Color) -> Self {
        var copy = self
        copy.borderColor = borderColor
        return copy
    }
    
    public func hoverBorderColor(_ hoverBorderColor: Color) -> Self {
        var copy = self
        copy.hoverBorderColor = hoverBorderColor
        return copy
    }
    
    public func borderWidth(_ borderWidth: CGFloat) -> Self {
        var copy = self
        copy.borderWidth = borderWidth
        return copy
    }
    
    public func hoverBorderWidth(_ hoverBorderWidth: CGFloat) -> Self {
        var copy = self
        copy.hoverBorderWidth = hoverBorderWidth
        return copy
    }
    
    public func paddingWidth(_ paddingWidth: CGFloat) -> Self {
        var copy = self
        copy.paddingWidth = paddingWidth
        return copy
    }
}
