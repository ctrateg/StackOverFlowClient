import Foundation

struct AnswersResponseDTO: Codable {
    let hasMore: Bool
    let items: [AnswersDTO]
    let quotaMax: Int
    let quotaRemaining: Int
}
