import Alamofire

class GetRequestClass{
    var message: QuestionResponseDTO?
    
    let urlString = "https://api.stackexchange.com//2.3/questions?page=1&pagesize=20&order=desc&sort=activity&site=stackoverflow"
    
    func getRequest(completion: @escaping (QuestionResponseDTO) -> Void){
        Alamofire.request(urlString).validate().responseJSON{ responce in
            switch responce.result {
            
            case .success(_):
                if let jsonData = responce.data {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    do {
                        let returnData = try jsonDecoder.decode(QuestionResponseDTO.self, from: jsonData)
                        
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
