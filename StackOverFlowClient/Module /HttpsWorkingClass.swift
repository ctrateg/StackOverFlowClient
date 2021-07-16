import SwiftSoup


class HttpsWorkingClass {
    var message: QuestionResponseDTO?
    
    //запрос для получения данных по вопросу
    func requestQestion(page: String = "1", tag: String, completion: @escaping (QuestionResponseDTO) -> Void){
        guard let url = URL(string: "https://api.stackexchange.com//2.3/questions?page=\(page)&pagesize=20&order=desc&sort=activity&tagged=\(tag)&site=stackoverflow") else { return }
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, request, error) in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
                do {
                    let returnData = try jsonDecoder.decode(QuestionResponseDTO.self, from: data!)
                    
                    completion(returnData)
                } catch let error as NSError {
                    print("\(error), \(error.userInfo)")
                }
            }
            task.resume()
    }
    
    //запрос по qestionId для получения данных по answers на него
    func requestAnswers(ids: String, completion: @escaping (AnswersResponseDTO) -> Void){
        guard let url = URL(string: "https://api.stackexchange.com/2.3/questions/\(ids)/answers?order=desc&sort=activity&site=stackoverflow") else { return }
        
        let task = URLSession.shared.dataTask(with: url) {
        (data, request, error) in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
            do {
                let returnData = try jsonDecoder.decode(AnswersResponseDTO.self, from: data!)
                print("loaded")
                completion(returnData)
            } catch let error as NSError {
                print("\(error), \(error.userInfo)")
            }
        }
        task.resume()
    }
    
    //получение текста с сайта по ирл qestion
    func htmlRequest(_ url: String, completion: @escaping ([String]) -> Void){
        guard let htmlUrl = URL(string: url) else { return }
        
        do {
            let htmlString = try String(contentsOf: htmlUrl, encoding: .utf8)
            let htmlContent = htmlString
            
            do {
                let doc: Document = try SwiftSoup.parse(htmlContent)
                let elements = try doc.getElementsByClass("post-layout").array()
                var returnData: [String] = []
                
                for element in elements {
                    guard let text = try element.getElementsByClass("s-prose js-post-body").first()?.text() else { return }
                    returnData.append(text)
                }
                
                completion(returnData)
            } catch Exception.Error(type: let type, Message: let message) {
                print(message, type)
            } catch {
                print("error")
            }
        } catch let error{
            print("Error:\(error)")
        }
    }
}
