import UIKit
import Foundation

class PrimaryTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let getRequestClass = GetRequestClass()
    var dataJson: [QuestionDTO] = []
    
    var tagRequest: String = "swift"
    var pickerData = ["swift", "objective-c", "ios", "xcode", "cocoa_touch", "iphone"]
    
    var pickerView: UIPickerView = UIPickerView()
    
    //эти части интерфейса как индикатор и пикер реализованны в коде, чтоб не нагромождать интерфейс билдер
    let loadView = UIView()
    let indicator = UIActivityIndicatorView()
    let loadLabel = UILabel()
    
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
            cell.editData.text = dateOutput(editDate)
        } else {
            cell.editData.text = unwarpDate(creatDate)
        }
        
        
        return cell
    }

    func request(tag: String){
        setLoadingScreen()
        getRequestClass.getRequest(tag: tag){ [weak self] searchResponce in
            self?.dataJson = searchResponce.items
            self?.tableView.reloadData()
        }
        navigationController?.topViewController?.title = tag
        removeLoadingScreen()
    }
    
    func dateOutput(_ date: Int) -> String {
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
            //date without time
            return unwarpDate(date)
        }
    }
    
    
    
    func unwarpDate(_ date:Int) -> String {
        //var secondFromGMT: Int { return TimeZone.current.secondsFromGMT() }
        //let timeZoneDate = date + secondFromGMT
        
        let formatter = DateFormatter()
        let dateInterval = TimeInterval(date)
        let dateOutput = Date(timeIntervalSince1970: dateInterval)
        formatter.dateStyle = .long
        
        return formatter.string(from: dateOutput)
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
            tagRequest = tagRequestChange
            
            request(tag: tagRequest)
            
            pickerView.isHidden = true

            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func setLoadingScreen(){
        // Sets the view which contains the loading text and the spinner
               let width: CGFloat = 120
               let height: CGFloat = 30
               let x = (tableView.frame.width / 2) - (width / 2)
               let y = (tableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        
               loadView.frame = CGRect(x: x, y: y, width: width, height: height)

               loadLabel.textColor = .darkGray
               loadLabel.textAlignment = .center
               loadLabel.text = "Loading..."
               loadLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)

               indicator.style = .gray
               indicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
               indicator.startAnimating()

               loadView.addSubview(indicator)
               loadView.addSubview(loadLabel)

               tableView.addSubview(loadView)
    }
    
    private func removeLoadingScreen(){
        // Hides and stops the text and the spinner
              indicator.stopAnimating()
              indicator.isHidden = true
              loadLabel.isHidden = true
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
