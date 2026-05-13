import SwiftUI

enum Theme {
    static let primary = Color(red: 255/255, green: 140/255, blue: 0/255) // Copper/Orange
    static let secondary = Color.blue
    static let success = Color.green
    static let background = Color.black
    
    // Un gris muy oscuro para el fondo de las vistas que no son ZStack
    static let secondaryBackground = Color(white: 0.05)
    
    static let primaryGradient = LinearGradient(
        colors: [Color(red: 255/255, green: 140/255, blue: 0/255), Color(red: 200/255, green: 100/255, blue: 0/255)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryGradient = LinearGradient(
        colors: [Color.blue, Color.blue.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [Color.green, Color.green.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardBackground = Color(white: 0.12)
    static let glassBackground = Color(white: 0.18).opacity(0.8)
    
    static let cornerRadius: CGFloat = 20
    static let innerCornerRadius: CGFloat = 14
    
    struct CardModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding()
                .background(Theme.glassBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        }
    }
}

extension View {
    func fitnessCard() -> some View {
        self.modifier(Theme.CardModifier())
    }
}
