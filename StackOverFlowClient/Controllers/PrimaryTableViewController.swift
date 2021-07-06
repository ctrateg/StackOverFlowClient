import UIKit
import Foundation

class PrimaryTableViewController: UITableViewController {
    let getRequestClass = GetRequestClass()
    var dataJson: [QuestionDTO] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRequestClass.getRequest(){ [weak self] searchResponce in
            self?.dataJson = searchResponce.items
            self?.tableView.reloadData()
        }
        
        
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
        let time:Int = dataJson[indexPath.row].answerCount ?? 0
        let commentsInt: Int = dataJson[indexPath.row].answerCount ?? 0
        
        cell.qestion.text = dataJson[indexPath.row].title
        cell.answeringPerson.text = dataJson[indexPath.row].owner?.displayName
        cell.comments.text = "Ответов:" + String(commentsInt)
        cell.editData.text = String(describing: dataJson[indexPath.row].lastEditDate)
        
        return cell
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
