import Foundation

/// Lifecycle state of a co-located outdoor event.
public enum EventStatus: String, Codable, Sendable, CaseIterable, Hashable {
    case draft
    case lobby
    case live
    case ended
}
