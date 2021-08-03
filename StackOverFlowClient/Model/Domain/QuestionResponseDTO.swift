import Foundation

struct QuestionResponseDTO: Codable {
    let hasMore: Bool
    let items: [QuestionDTO]
    let quotaMax: Int
    let quotaRemaining: Int
}
