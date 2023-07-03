//
//  DelayedAnimation.swift
//  EthereumWrapperDemo
//
//  Created by Harrison Friia on 6/30/23.
//

import SwiftUI

struct DelayedAnimation: ViewModifier {
    var delay: Double
    var animation: Animation = .default

    @State private var animating = false

    func delayAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(animation) {
                animating = true
            }
        }
    }

    func body(content: Content) -> some View {
        Group {
            if animating {
                content
            } else {
                content.opacity(0)
            }
        }
        .onAppear(perform: delayAnimation)
    }
}

extension View {
    func delayedAnimation(delay: Double = 0.25, animation: Animation = .default) -> some View {
        modifier(DelayedAnimation(delay: delay, animation: animation))
    }
}
