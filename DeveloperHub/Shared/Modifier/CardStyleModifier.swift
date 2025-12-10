//
//  CardStyleModifier.swift
//  DeveloperHub
//
//  Created by Saurabh on 10/12/25.
//


// Shared/Modifiers/CardStyleModifier.swift
import SwiftUI

struct CardStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyleModifier())
    }
}
