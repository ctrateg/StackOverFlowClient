import UIKit
import SwiftSoup

class QestionPostTableViewController: UITableViewController {
    var link: String?
    
    lazy var stackExchangeApiService = {
        return StackExchangeApiService()
    }()
    
    private var dataJson: [AnswersDTO] = []
    private var htmlText: [String] = []
    var qestionNickName: String?
    var qestionLastEditDate: Int?
    var qestionCreationDate: Int?
    var qestionId: Int?
    var qestionScore: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerRequest(ids: "\(qestionId ?? Utility.defaultInt)")
        requestHtml(link: link ?? Utility.emptyString)
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Идет обновление...")
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return htmlText.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QestionPostTableViewCell", for: indexPath) as! QestionPostTableViewCell
        let htmlValue = htmlText[indexPath.row]
        let answerRow = indexPath.row - 1
        
        cell.textSTVC.text = htmlValue
        
        if indexPath.row == 0{
            cell.nickNameSTVC.text = qestionNickName
            cell.raitingSTVC.text = String(qestionScore ?? Utility.defaultInt)
            cell.dateModificatedSTVC.text = date(creationDate: qestionCreationDate, lastEditDate: qestionLastEditDate)
            cell.backgroundColor = .lightGray
        } else {
            cell.nickNameSTVC.text = dataJson[answerRow].owner?.displayName
            cell.raitingSTVC.text = String(dataJson[answerRow].score ?? Utility.defaultInt)
            cell.dateModificatedSTVC.text = date(creationDate: dataJson[answerRow].creationData, lastEditDate: dataJson[answerRow].lastActivityDate)
            cell.backgroundColor = .white
            
            switch answerCheckMark(row: answerRow) {
            case true:
                cell.accessoryType = .checkmark
            case false:
                break
            }
        }
        return cell
    }
    
    //запрос с обновлением таблицы
    func answerRequest(ids: String){
        navigationItem.hidesBackButton = true
        DispatchQueue.global(qos: .background).sync {
            self.stackExchangeApiService.requestAnswers(ids: ids){ [weak self] searchResponce in
                self?.dataJson = searchResponce.items
            
                DispatchQueue.main.sync {
                    self?.tableView.reloadData()
                    self?.navigationItem.hidesBackButton = false
                }
            }
        }
    }
    
    //получение текста
    func requestHtml(link: String){
        DispatchQueue.global(qos: .background).sync {
            self.stackExchangeApiService.requestHttps(link){ [weak self] searchResponce in
                self?.htmlText = searchResponce
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    // подводка к дате в полоном виде
    func date(creationDate: Int?, lastEditDate: Int?) -> String{
        if qestionLastEditDate == nil {
            return Utility.unwarpDate(creationDate ?? Utility.defaultInt)
        } else {
            return Utility.dateOutput(lastEditDate ?? Utility.defaultInt)
        }
    }
    
    //проверка на наличие галочки на ответе
    func answerCheckMark(row: Int) -> Bool{
        if dataJson[row].isAccepted == true{
            return true
        } else {
            return false
        }
    }
    
    //Обновление по свайпу вниз
    @objc func refresh() {
        refreshBegin(link: link ?? Utility.emptyString, refreshEnd: {(x:Int) -> () in
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
        
    func refreshBegin(link:String, refreshEnd: @escaping(Int) -> ()) {
            DispatchQueue.global(qos: .default).async() {
                self.requestHtml(link: link)
                sleep(2)
                
                DispatchQueue.main.async() {
                    refreshEnd(0)
                }
            }
        }
}
