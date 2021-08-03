import Foundation

struct  AnswersDTO: Codable{
    let owner: OwnerDTO?
    let isAccepted: Bool?
    let score: Int?
    let lastActivityDate: Int?
    let creationData: Int?
    let answerId: Int?
    let qestionId: Int?
    let contentLicense: String?
}
