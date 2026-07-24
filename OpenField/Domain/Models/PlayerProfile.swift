import Foundation

/// Local player identity and sharing preferences.
public struct PlayerProfile: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var displayName: String
    public var locationSharingEnabled: Bool

    public init(
        id: UUID = UUID(),
        displayName: String,
        locationSharingEnabled: Bool = true
    ) {
        self.id = id
        self.displayName = displayName
        self.locationSharingEnabled = locationSharingEnabled
    }
}
