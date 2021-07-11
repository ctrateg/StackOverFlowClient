import Foundation

struct QuestionDTO: Codable{
    let acceptedAnswerId: Int?
    let answerCount: Int?
    let contentLicense: String?
    let creationDate: Int?
    let isAnswered: Bool?
    let lastActivityDate: Int?
    let lastEditDate: Int?
    let link: String?
    let owner: OwnerDTO?
    let questionId: Int?
    let score: Int?
    let tags: [String]
    let title: String?
    let viewCount: Int?
}
