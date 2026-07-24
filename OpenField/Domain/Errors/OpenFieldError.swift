import Foundation

public enum EventStoreError: Error, LocalizedError, Sendable, Equatable {
    case eventNotFound(UUID)
    case joinCodeNotFound(String)
    case membershipNotFound
    case teamNotFound(UUID)
    case markerNotFound(UUID)
    case messageNotFound(UUID)
    case invalidJoinCode(String)
    case notAuthorized
    case conflict(String)
    case notImplemented(String)

    public var errorDescription: String? {
        switch self {
        case .eventNotFound(let id):
            return "Event not found: \(id.uuidString)."
        case .joinCodeNotFound(let code):
            return "No event matches join code “\(code)”."
        case .membershipNotFound:
            return "Membership not found."
        case .teamNotFound(let id):
            return "Team not found: \(id.uuidString)."
        case .markerNotFound(let id):
            return "Map marker not found: \(id.uuidString)."
        case .messageNotFound(let id):
            return "Chat message not found: \(id.uuidString)."
        case .invalidJoinCode(let code):
            return "Invalid join code “\(code)”."
        case .notAuthorized:
            return "You are not authorized to perform this action."
        case .conflict(let message):
            return message
        case .notImplemented(let feature):
            return "Not implemented yet: \(feature)."
        }
    }
}

public enum LocationServiceError: Error, LocalizedError, Sendable, Equatable {
    case permissionDenied
    case permissionRestricted
    case locationUnknown
    case servicesDisabled

    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission was denied."
        case .permissionRestricted:
            return "Location access is restricted on this device."
        case .locationUnknown:
            return "Current location is not available."
        case .servicesDisabled:
            return "Location services are disabled."
        }
    }
}
