import UIKit
import SnapKit

class CourseWishlistTableViewCell: UITableViewCell {
    
    var courseLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        courseLabel = UILabel()
        courseLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        contentView.addSubview(courseLabel)
    }
    
    override func updateConstraints() {
        courseLabel.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(contentView.snp.centerY)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
        }
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addInfo(course: String) {
        courseLabel.text = course
    }
}
