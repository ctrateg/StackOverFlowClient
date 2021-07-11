import Alamofire

class GetRequestClass{
    var message: QuestionResponseDTO?
    
    func getRequest(page:String = "1", tag: String, completion: @escaping (QuestionResponseDTO) -> Void){
        
        let urlString = "https://api.stackexchange.com//2.3/questions?page=\(page)&pagesize=20&order=desc&sort=activity&tagged=\(tag)&site=stackoverflow"
        
        //let urlString = "https://api.stackexchange.com/docs/posts-by-ids#order=desc&sort=activity&ids=68277149&filter=default&site=stackoverflow"
        
        Alamofire.request(urlString).validate().responseJSON{ responce in
            switch responce.result {
            
            case .success(_):
                if let jsonData = responce.data {
                    let jsonDecoder = JSONDecoder()
                    
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    do {
                        let returnData = try jsonDecoder.decode(QuestionResponseDTO.self, from: jsonData)
                        print(returnData)
                        completion(returnData)
                    } catch let error {
                        print(String(describing: error))
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }.resume()
    }
}
