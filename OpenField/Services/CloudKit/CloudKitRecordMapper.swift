import Foundation

/// Documents how domain types will map onto CloudKit records later.
/// Pure key/value sketches — no `CKRecord` construction (avoids requiring CloudKit capability).
public enum CloudKitRecordMapper {
    public static func eventFields(from event: RallyEvent) -> [String: any Sendable] {
        [
            CloudKitFieldKey.Event.title: event.title,
            CloudKitFieldKey.Event.description: event.description,
            CloudKitFieldKey.Event.rulesText: event.rulesText,
            CloudKitFieldKey.Event.status: event.status.rawValue,
            CloudKitFieldKey.Event.joinCode: event.joinCode,
            CloudKitFieldKey.Event.hostUserId: event.hostUserId.uuidString,
            CloudKitFieldKey.Event.createdAt: event.createdAt,
            CloudKitFieldKey.Event.updatedAt: event.updatedAt,
        ]
    }

    public static func teamFields(from team: Team) -> [String: any Sendable] {
        [
            CloudKitFieldKey.Team.eventId: team.eventId.uuidString,
            CloudKitFieldKey.Team.name: team.name,
            CloudKitFieldKey.Team.colorRed: team.colorRed,
            CloudKitFieldKey.Team.colorGreen: team.colorGreen,
            CloudKitFieldKey.Team.colorBlue: team.colorBlue,
            CloudKitFieldKey.Team.memberUserIds: team.memberUserIds.map(\.uuidString),
        ]
    }

    public static func markerFields(from marker: MapMarkerItem) -> [String: any Sendable] {
        [
            CloudKitFieldKey.Marker.eventId: marker.eventId.uuidString,
            CloudKitFieldKey.Marker.kind: marker.kind.rawValue,
            CloudKitFieldKey.Marker.title: marker.title,
            CloudKitFieldKey.Marker.detail: marker.detail,
            CloudKitFieldKey.Marker.latitude: marker.latitude,
            CloudKitFieldKey.Marker.longitude: marker.longitude,
            CloudKitFieldKey.Marker.status: marker.status.rawValue,
            CloudKitFieldKey.Marker.order: marker.order,
        ]
    }

    public static func membershipFields(from membership: Membership) -> [String: any Sendable] {
        var fields: [String: any Sendable] = [
            CloudKitFieldKey.Membership.eventId: membership.eventId.uuidString,
            CloudKitFieldKey.Membership.userId: membership.userId.uuidString,
            CloudKitFieldKey.Membership.isHost: membership.isHost,
        ]
        if let teamId = membership.teamId {
            fields[CloudKitFieldKey.Membership.teamId] = teamId.uuidString
        }
        return fields
    }

    public static func chatMessageFields(from message: ChatMessage) -> [String: any Sendable] {
        [
            CloudKitFieldKey.ChatMessage.eventId: message.eventId.uuidString,
            CloudKitFieldKey.ChatMessage.senderId: message.senderId.uuidString,
            CloudKitFieldKey.ChatMessage.senderName: message.senderName,
            CloudKitFieldKey.ChatMessage.body: message.body,
            CloudKitFieldKey.ChatMessage.createdAt: message.createdAt,
        ]
    }

    public static func locationPingFields(from ping: LocationPing) -> [String: any Sendable] {
        var fields: [String: any Sendable] = [
            CloudKitFieldKey.LocationPing.eventId: ping.eventId.uuidString,
            CloudKitFieldKey.LocationPing.userId: ping.userId.uuidString,
            CloudKitFieldKey.LocationPing.displayName: ping.displayName,
            CloudKitFieldKey.LocationPing.latitude: ping.latitude,
            CloudKitFieldKey.LocationPing.longitude: ping.longitude,
            CloudKitFieldKey.LocationPing.updatedAt: ping.updatedAt,
        ]
        if let teamId = ping.teamId {
            fields[CloudKitFieldKey.LocationPing.teamId] = teamId.uuidString
        }
        return fields
    }
}
