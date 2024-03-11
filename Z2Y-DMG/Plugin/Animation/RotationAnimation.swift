//
//  RotationAnimation.swift
//  Z2Y
//
//  Created by Oyjie on 2023/12/19.
//

import Foundation
import SwiftUI

public struct RotationAnimation<Label>: View where Label: View {
    public var maxRotation: Angle = Angle.init(degrees: 360)
    public let label: () -> Label
    
    @State private var rotation: Angle = Angle.zero
    public init(maxRotation: Angle = Angle.init(degrees: 360), label: @escaping () -> Label, rotation: Angle = Angle.zero) {
        self.maxRotation = maxRotation
        self.label = label
        self.rotation = rotation
    }
    
    public var body: some View {
        self.label().rotationEffect(self.rotation).onAppear {
            withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                self.rotation = self.maxRotation
            }
        }
    }
}
