import Foundation

struct Entry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var country: String
    var crossingPoint: String
    var stayDays: Double
    var visitCount: Double
    var date: Date = Date()
    var notes: String = ""
}
