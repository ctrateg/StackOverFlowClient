import Foundation

class Utility {
    static let emptyString = ""
    static let defaultInt = 0
    
    // дата в умном виде
    static func dateOutput(_ date: Int) -> String {
        let timeNow = Int(Date().timeIntervalSince1970)
        let difference = timeNow - date
        
        if difference <= 86400 {
            switch difference{
            case 0...60:
                return "modified \(difference) secs ago"
            case 60...3600:
                return "modified \(difference/60) minutes ago"
            default:
                return "modified \(difference/3600) hours ago"
            }
        } else {
            return unwarpDate(date)
        }
    }
    
    //парс даты
    static func unwarpDate(_ date:Int) -> String {
        switch date {
        case 0:
            return ""
        default:
            let formatter = DateFormatter()
            let dateInterval = TimeInterval(date)
            let dateOutput = Date(timeIntervalSince1970: dateInterval)
            formatter.dateStyle = .long
            
            return formatter.string(from: dateOutput)
        }
    }
}
