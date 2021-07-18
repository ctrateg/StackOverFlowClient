import SwiftSoup

class StackExchangeApiService {
    let jsonDecoder = JSONDecoder()
    let stackExchangeApi = "https://api.stackexchange.com//2.3/questions"
    
    //запрос для получения данных по вопросу
    func requestQuestion(page: String = "1", pagesize:Int = 20, tag: String, completion: @escaping (QuestionResponseDTO) -> Void){
        
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let url = URL(string: "\(stackExchangeApi)?page=\(page)&pagesize=\(pagesize)&order=desc&sort=activity&tagged=\(tag)&site=stackoverflow") else { return }
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, request, error) in
            
                do {
                    let returnData = try self.jsonDecoder.decode(QuestionResponseDTO.self, from: data!)
                    
                    completion(returnData)
                } catch let error as NSError {
                    print("\(error), \(error.userInfo)")
                }
            }
            task.resume()
    }
    
    //запрос по qestionId для получения данных по answers на него
    func requestAnswers(ids: String, completion: @escaping (AnswersResponseDTO) -> Void){
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let url = URL(string: "\(stackExchangeApi)/\(ids)/answers?order=desc&sort=activity&site=stackoverflow") else { return }
        
        let task = URLSession.shared.dataTask(with: url) {
        (data, request, error) in
        
            do {
                let returnData = try self.jsonDecoder.decode(AnswersResponseDTO.self, from: data!)
                completion(returnData)
            } catch let error as NSError {
                print("\(error), \(error.userInfo)")
            }
        }
        task.resume()
    }
    
    //получение текста с сайта по ирл qestion
    func requestHttps(_ url: String, elementClass: String = "post-layout", completion: @escaping ([String]) -> Void){
        guard let htmlUrl = URL(string: url) else { return }
        
        do {
            let htmlString = try String(contentsOf: htmlUrl, encoding: .utf8)
            let htmlContent = htmlString
            
            do {
                let doc: Document = try SwiftSoup.parse(htmlContent)
                let elements = try doc.getElementsByClass(elementClass).array()
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