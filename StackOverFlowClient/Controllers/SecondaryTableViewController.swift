import UIKit
import SwiftSoup

class SecondaryTableViewController: UITableViewController {
    var link: String?
    let httpsWorkingClass = HttpsWorkingClass()
    var dataJson: [AnswersDTO] = []
    var htmlText: [String] = []
    var qestionNickName: String?
    var qestionLastEditDate: Int?
    var qestionCreationDate: Int?
    var qestionId: Int?
    var qestionScore: Int?
    
    @IBOutlet weak var refreshIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerRequest(ids: "\(qestionId ?? 0)")
        requestHtml(link: link ?? "")
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SecondaryTableViewCell", for: indexPath) as! SecondaryTableViewCell
        let htmlValue = htmlText[indexPath.row]
        let answerRow = indexPath.row - 1
        
        cell.textSTVC.text = htmlValue
        
        if indexPath.row == 0 {
            cell.nickNameSTVC.text = qestionNickName
            cell.raitingSTVC.text = String(qestionScore ?? 0)
            cell.dateModificatedSTVC.text = date(creationDate: qestionCreationDate, lastEditDate: qestionLastEditDate)
        } else {
            cell.nickNameSTVC.text = dataJson[answerRow].owner?.displayName
            cell.raitingSTVC.text = String(dataJson[answerRow].score ?? 0)
            cell.dateModificatedSTVC.text = date(creationDate: dataJson[answerRow].creationData, lastEditDate: dataJson[answerRow].lastActivityDate)
            
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
        httpsWorkingClass.requestAnswers(ids: ids){ [weak self] searchResponce in
            self?.dataJson = searchResponce.items
            DispatchQueue.main.sync {
                self?.tableView.reloadData()
            }
        }
    }
    
    //получение текста
    func requestHtml(link: String){
        DispatchQueue.global(qos: .default).async(qos:.background) {
            self.httpsWorkingClass.htmlRequest(link){ [weak self] searchResponce in
                self?.htmlText = searchResponce
            
                DispatchQueue.main.sync {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    // подводка к дате в полоном виде
    func date(creationDate: Int?, lastEditDate: Int?) -> String{
        if qestionLastEditDate == nil {
            return Utility.unwarpDate(creationDate ?? 0)
        } else {
            return Utility.dateOutput(lastEditDate ?? 0)
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
        refreshBegin(link: link ?? "", refreshEnd: {(x:Int) -> () in
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