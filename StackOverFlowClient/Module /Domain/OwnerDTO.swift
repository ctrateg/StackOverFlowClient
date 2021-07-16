import Foundation

struct OwnerDTO: Codable {
    let accountId: Int?
    let displayName: String?
    let link: String?
    let profileImage: String?
    let reputation: Int?
    let userId: Int?
    
    
    enum UserType: String, Codable {
        case unregistered, registered, moderator, teamAdmin, doesNotExist
    }
}
