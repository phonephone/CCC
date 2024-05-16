//
//  ShareTemplate.swift
//  CCC
//
//  Created by Truk Karawawattana on 9/5/2565 BE.
//

import Foundation
import UIKit

class ShareTemplate: UIView {
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var timeIcon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var distanceTitle: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSuffix: UILabel!
    
    @IBOutlet weak var calorieTitle: UILabel!
    @IBOutlet weak var calorieIcon: UIImageView!
    @IBOutlet weak var calorieLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //commonInit()
    }
    
    func commonInit(withTemplate:Int, withTextColor:UIColor){
        var viewFromXib = UIView()
        
        viewFromXib = Bundle.main.loadNibNamed("ShareTemplate\(withTemplate)", owner: self, options: nil)![0] as! UIView
        
//        switch withTemplate {
//        case 1:
//            viewFromXib = Bundle.main.loadNibNamed("ShareTemplate1", owner: self, options: nil)![0] as! UIView
//            
//        case 2:
//            viewFromXib = Bundle.main.loadNibNamed("ShareTemplate2", owner: self, options: nil)![0] as! UIView
//            
//        default:
//            viewFromXib = Bundle.main.loadNibNamed("ShareTemplate1", owner: self, options: nil)![0] as! UIView
//        }
        
        dateLabel.textColor = withTextColor
        
        timeTitle.textColor = withTextColor
        timeIcon.setImageColor(color: withTextColor)
        timeLabel.textColor = withTextColor
        
        distanceTitle.textColor = withTextColor
        distanceLabel.textColor = withTextColor
        distanceSuffix.textColor = withTextColor
        
        calorieTitle.textColor = withTextColor
        calorieIcon.setImageColor(color: withTextColor)
        calorieLabel.textColor = withTextColor
        
//        let viewFromXib = Bundle.main.loadNibNamed("ShareTemplate", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        
        addSubview(viewFromXib)
    }
}
