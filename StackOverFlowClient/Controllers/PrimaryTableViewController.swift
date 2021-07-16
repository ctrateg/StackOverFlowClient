import UIKit
import Foundation
import SwiftSoup

class PrimaryTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var refreshIndicattor: UIActivityIndicatorView!
    
    let httpsWorkingClass = HttpsWorkingClass()
    var dataJson: [QuestionDTO] = []
    var tagRequest: String = "swift"
    var pickerData = ["swift", "objective-c", "ios", "xcode", "cocoa_touch", "iphone"]
    var page = 1
    var loadMoreStatus = false
    
    //эти части интерфейса как индикатор и пикер реализованны в коде, чтоб не нагромождать интерфейс билдер
    let loadView = UIView()
    let indicator = UIActivityIndicatorView()
    var pickerView: UIPickerView = UIPickerView()
    
    //button для вызова пикера
    @IBAction func tagPicker(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        alert.isModalInPopover = true
        
        pickerView.frame = CGRect(x: 8.0, y: 8.0, width: alert.view.bounds.size.width - 32.5, height: 202.5)
        
        if pickerView.isHidden {
            pickerView.isHidden = false
        }
        
        alert.view.addSubview(pickerView)
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        request(tag: tagRequest)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        pickerView.isHidden = true
        pickerView.backgroundColor = .white
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Идет обновление...")
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataJson.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrimaryTableViewCell", for: indexPath) as! PrimaryTableViewCell
        let commentsInt: Int = dataJson[indexPath.row].answerCount ?? 0
        let dataRow = dataJson[indexPath.row]
        let qestionString: String = dataRow.title ?? ""
        let answeringPersonString: String = dataRow.owner?.displayName ?? ""
        let editDate: Int = dataRow.lastEditDate ?? 0
        let creatDate: Int = dataRow.creationDate ?? 0
        
        cell.qestion.text = qestionString.htmlDecoded
        cell.answeringPerson.text = answeringPersonString.htmlDecoded
        cell.comments.text = "Ответов:" + String(commentsInt)
        
        if editDate != 0 {
            cell.editData.text = Utility.dateOutput(editDate)
        } else {
            cell.editData.text = Utility.unwarpDate(creatDate)
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SegueSecond") {
            let controller = segue.destination as! SecondaryTableViewController
            let row = tableView.indexPathForSelectedRow?.row ?? 0
            
            controller.link = dataJson[row].link
            controller.qestionId = dataJson[row].questionId
            controller.qestionLastEditDate = dataJson[row].lastEditDate
            controller.qestionCreationDate = dataJson[row].creationDate
            controller.qestionScore = dataJson[row].score
            controller.qestionNickName = dataJson[row].owner?.displayName?.htmlDecoded
        }
    }

    // запрос по тегу для первого тбв
    func request(tag: String, page: String = "1"){
        setLoadingScreen()
        
        httpsWorkingClass.requestQestion(page: page, tag: tag){ [weak self] searchResponce in
            self?.dataJson = searchResponce.items
            DispatchQueue.main.sync {
                self?.tableView.reloadData()
            }
        }
        self.page = 1
        
        removeLoadingScreen()
        
        navigationController?.topViewController?.title = tag
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let tagRequestChange = pickerData[row]
        
        if tagRequest == tagRequestChange {
            pickerView.isHidden = true
        } else {
            pickerView.isHidden = true
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
            tagRequest = tagRequestChange
            request(tag: tagRequest)
        }
        dismiss(animated: true, completion: nil)
    }
    
    // экран индикатора при подгрузках
    private func setLoadingScreen(){
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 50
        let height: CGFloat = 30
        let x = (tableView.frame.width / 2) - (width / 2)
        let y = (tableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        
        loadView.frame = CGRect(x: x, y: y, width: width, height: height)

        indicator.style = .gray
        indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        indicator.startAnimating()

        loadView.addSubview(indicator)

        tableView.addSubview(loadView)
        tableView.isScrollEnabled = false
        sleep(2)
    }
    
    private func removeLoadingScreen(){
        indicator.stopAnimating()
        indicator.isHidden = true
        
        tableView.isScrollEnabled = true
    }
    
    //обновление по свайпу вниз
    @objc func refresh() {
        refreshBegin(tag: tagRequest, refreshEnd: {(x:Int) -> () in
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            })
        }
        
    func refreshBegin(tag:String, refreshEnd: @escaping(Int) -> ()) {
            DispatchQueue.global(qos: .default).async() {
                self.httpsWorkingClass.requestQestion(tag: tag){ [weak self] searchResponce in
                    self?.dataJson = searchResponce.items
                    
                    DispatchQueue.main.sync {
                        self?.tableView.reloadData()
                    }
                }
                sleep(2)
                
                DispatchQueue.main.async() {
                    refreshEnd(0)
                }
            }
        }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            loadMore()
        }
    }
    
    func loadMore() {
        if ( !loadMoreStatus ) {
            self.loadMoreStatus = true
            self.setLoadingScreen()
            loadMoreBegin(tag: tagRequest, loadMoreEnd: {(x:Int) -> () in
                self.tableView.reloadData()
                self.loadMoreStatus = false
                self.removeLoadingScreen()
            })
        }
    }
    
    func loadMoreBegin(tag:String, loadMoreEnd: @escaping(Int) -> ()) {
        DispatchQueue.global(qos: .default).async() {
            self.page += 1
            
            self.httpsWorkingClass.requestQestion(page: "\(self.page)", tag: tag){ [weak self] searchResponce in
                self?.dataJson += searchResponce.items
            sleep(2)
               
            DispatchQueue.main.async() {
                   loadMoreEnd(0)
               }
           }
       }
    }
}
