import Foundation

/// CloudKit record type names for the future adapter.
/// Do not open a live `CKContainer` from scaffolding code.
public enum CloudKitRecordType {
    public static let event = "FieldEvent"
    public static let team = "FieldTeam"
    public static let marker = "FieldMarker"
    public static let membership = "FieldMembership"
    public static let profile = "FieldProfile"
    public static let chatMessage = "FieldChatMessage"
    public static let locationPing = "FieldLocationPing"
}

/// Field key constants for mapping domain models ↔ `CKRecord`.
/// Sketch only — no live CloudKit I/O in this target.
public enum CloudKitFieldKey {
    public enum Event {
        public static let title = "title"
        public static let description = "descriptionText"
        public static let rulesText = "rulesText"
        public static let status = "status"
        public static let joinCode = "joinCode"
        public static let hostUserId = "hostUserId"
        public static let createdAt = "createdAt"
        public static let updatedAt = "updatedAt"
    }

    public enum Team {
        public static let eventId = "eventId"
        public static let name = "name"
        public static let colorRed = "colorRed"
        public static let colorGreen = "colorGreen"
        public static let colorBlue = "colorBlue"
        public static let memberUserIds = "memberUserIds"
    }

    public enum Marker {
        public static let eventId = "eventId"
        public static let kind = "kind"
        public static let title = "title"
        public static let detail = "detail"
        public static let latitude = "latitude"
        public static let longitude = "longitude"
        public static let status = "status"
        public static let order = "order"
    }

    public enum Membership {
        public static let eventId = "eventId"
        public static let userId = "userId"
        public static let teamId = "teamId"
        public static let isHost = "isHost"
    }

    public enum Profile {
        public static let displayName = "displayName"
        public static let locationSharingEnabled = "locationSharingEnabled"
    }

    public enum ChatMessage {
        public static let eventId = "eventId"
        public static let senderId = "senderId"
        public static let senderName = "senderName"
        public static let body = "body"
        public static let createdAt = "createdAt"
    }

    public enum LocationPing {
        public static let eventId = "eventId"
        public static let userId = "userId"
        public static let teamId = "teamId"
        public static let displayName = "displayName"
        public static let latitude = "latitude"
        public static let longitude = "longitude"
        public static let updatedAt = "updatedAt"
    }
}
