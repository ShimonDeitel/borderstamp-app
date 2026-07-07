import SwiftUI

enum Theme {
    static let accent = Color(red: 0.541, green: 0.231, blue: 0.180)
    static let background = Color(red: 0.086, green: 0.043, blue: 0.031)
    static let card = background.opacity(0.6)
    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded)
    static let bodyFont = Font.system(.body, design: .rounded)
}
