import UIKit

class PrimaryTableViewCell: UITableViewCell {

    @IBOutlet weak var qestion: UILabel!
    @IBOutlet weak var answeringPerson: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var editData: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
