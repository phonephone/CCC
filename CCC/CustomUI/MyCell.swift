//
//  MyCell.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 5/11/2564 BE.
//

import UIKit
import SkeletonView

class SideMenuCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var menuImage: UIImageView!
    @IBOutlet var menuTitle: UILabel!
    @IBOutlet var menuAlert: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
        
        // Title
        //self.menuTitle.textColor = .white
    }
}

class ProfileCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var profileTitle: UILabel!
    @IBOutlet var profileDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
    }
}

class WorkOutCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellName: UILabel!
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellDuration: UILabel!
    @IBOutlet var cellDistance: UILabel!
    @IBOutlet var cellCalories: UILabel!
    @IBOutlet var cellImportBtn: UIButton!
    @IBOutlet var cellDeleteBtn: UIButton!
    @IBOutlet var cellReason: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
    }
}

class CategoryCell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
    }
}

class RankingCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellBackground: UIView!
    @IBOutlet var cellName: UILabel!
    @IBOutlet var cellCalories: UILabel!
    @IBOutlet var cellKCal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ChallengeCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellName: UILabel!
    @IBOutlet var cellDateIcon: UIImageView!
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellType: UIStackView!
    @IBOutlet var cellCompetitor: UILabel!
    @IBOutlet var cellGroup: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        [cellImage,cellName,cellDateIcon,cellDate,cellCompetitor].forEach{
            $0?.showAnimatedGradientSkeleton()
        }
    }
    
    func hideAnimation() {
        [cellImage,cellName,cellDateIcon,cellDate,cellCompetitor].forEach{
            $0?.hideSkeleton()
        }
    }
}

class KnowledgeCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class CreditCell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellDesc: UILabel!
    
    @IBOutlet var cellImage2: UIImageView!
    @IBOutlet var cellTitle2: UILabel!
    @IBOutlet var cellDesc2: UILabel!
    
    @IBOutlet var cellImage3: UIImageView!
    @IBOutlet var cellTitle3: UILabel!
    @IBOutlet var cellDesc3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
    }
}

class CreditHistoryCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellScore: UILabel!
    @IBOutlet var cellRemark: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class CreditListCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellDesc: UILabel!
    
    @IBOutlet var cellImage2: UIImageView!
    @IBOutlet var cellTitle2: UILabel!
    @IBOutlet var cellDesc2: UILabel!
    
    @IBOutlet var cellImage3: UIImageView!
    @IBOutlet var cellTitle3: UILabel!
    @IBOutlet var cellDesc3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
