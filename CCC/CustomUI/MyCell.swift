//
//  MyCell.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 5/11/2564 BE.
//

import UIKit

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
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellType: UIStackView!
    @IBOutlet var cellCompetitor: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
