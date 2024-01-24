//
//  Credit_2.swift
//  CCC
//
//  Created by Truk Karawawattana on 14/12/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SkeletonView

class Credit_2: UIViewController {
    
    var creditJSON: JSON?
    var assessmentJSON: JSON?
    var activityJSON: JSON?
    var specialJSON: JSON?
    
    var firstTime = true
    
    @IBOutlet weak var sideMenuBtn: UIButton!
    
    @IBOutlet weak var medalImage: UIImageView!
    @IBOutlet weak var medalLabel: UILabel!
    
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var remainLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressStack: UIStackView!
    
    @IBOutlet weak var menuBtn1: UIButton!
    @IBOutlet weak var menuBtn2: UIButton!
    @IBOutlet weak var menuBtn3: UIButton!
    @IBOutlet weak var menuBtn4: UIButton!
    
    @IBOutlet weak var menuBtnText1: UIButton!
    @IBOutlet weak var menuBtnText2: UIButton!
    @IBOutlet weak var menuBtnText3: UIButton!
    @IBOutlet weak var menuBtnText4: UIButton!
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var myStackView: UIStackView!
    
    @IBOutlet weak var assessmentStackView: UIStackView!
    @IBOutlet weak var activityStackView: UIStackView!
    @IBOutlet weak var specialStackView: UIStackView!
    
    @IBOutlet weak var assessmentTitle: UILabel!
    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var specialTitle: UILabel!
    
    @IBOutlet weak var assessmentCollectionView: UICollectionView!
    @IBOutlet weak var activityCollectionView: UICollectionView!
    @IBOutlet weak var specialCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCredit()
        
        firstTime = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CREDIT_2")
        
        self.view.showAnimatedGradientSkeleton()
        
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        myScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        assessmentCollectionView.dataSource = self
        assessmentCollectionView.delegate = self
        
        activityCollectionView.dataSource = self
        activityCollectionView.delegate = self
        
        specialCollectionView.dataSource = self
        specialCollectionView.delegate = self

        menuBtn2.disableIconBtn()
        menuBtnText2.disableIconBtn()
        menuBtn3.disableIconBtn()
        menuBtnText3.disableIconBtn()
        
        assessmentStackView.isHidden = true
        activityStackView.isHidden = true
        specialStackView.isHidden = true
    }
    
    func loadCredit() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        loadRequest_V2(method:.post, apiName:"credit", authorization:true, showLoadingHUD:firstTime, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS CREDIT\(json)")
                
                self.creditJSON = json["data"]
                
                self.assessmentJSON = self.creditJSON?["online_assessment"]
                self.activityJSON = self.creditJSON?["health_activities"]
                self.specialJSON = self.creditJSON?["special_activities"]
                
                self.assessmentCollectionView.reloadData()
                self.activityCollectionView.reloadData()
                self.specialCollectionView.reloadData()
                
                self.updateDisplay()
            }
        }
    }
    
    func updateDisplay() {
        
        if self.assessmentJSON?.count != 0 {
            assessmentStackView.isHidden = false
        }
        
        if self.activityJSON?.count != 0 {
            activityStackView.isHidden = false
        }
        
        if self.specialJSON?.count != 0 {
            specialStackView.isHidden = false
        }
        
        medalImage.sd_setImage(with: URL(string:creditJSON!["credit_level_url_image"].stringValue), placeholderImage: nil)
        medalLabel.text = creditJSON!["title_level_credit_text"].stringValue
        
        creditLabel.text = creditJSON!["my_credit_text"].stringValue
        remainLabel.text = creditJSON!["credit_next_level_text"].stringValue
        
        //progressBar.progress = 0.5
        progressBar.progress = creditJSON!["percent_bar"].floatValue
        progressStack.arrangedSubviews.forEach {//Clear stack
            $0.removeFromSuperview()
        }
        
        let levelArray = creditJSON!["credit_list"]
        print(levelArray.count)
        for i in 0...levelArray.count-1 {
            let label = UILabel()
            label.text = levelArray[i]["name_pointsLevel"].stringValue
            label.textColor = colorFromRGB(rgbString:levelArray[i]["color_code_rgb"].stringValue)
            //label.textColor = .white
            //label.backgroundColor = colorFromRGB(rgbString:levelArray[i]["color_code_rgb"].stringValue)
            label.font = .Prompt_Regular(ofSize: 14)
            
//            //if i < (levelArray.count)/2 {
//            if i == 0 {
//                label.textAlignment = .left
//            }
//            //else if i >= (levelArray.count)/2 {
//            else if i == levelArray.count-1 {
//
//                label.textAlignment = .right
//            }
//            else {
//                label.textAlignment = .center
//            }
//            //label.textAlignment = .center
            progressStack.addArrangedSubview(label)
        }
        
        assessmentTitle.text = creditJSON!["title_online_assessment"].stringValue
        activityTitle.text = creditJSON!["title_health_activities"].stringValue
        specialTitle.text = creditJSON!["title_special_activities"].stringValue
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.00) {
            self.view.hideSkeleton()
        }
    }
    
    @IBAction func leftMenuShow(_ sender: UIButton) {
        self.sideMenuController!.revealMenu()
    }
    
    @IBAction func menuClicked1(_ sender: UIButton) {
        let vc = UIStoryboard.creditStoryBoard.instantiateViewController(withIdentifier: "CreditHistory") as! CreditHistory
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func menuClicked2(_ sender: UIButton) {
        
    }
    
    @IBAction func menuClicked3(_ sender: UIButton) {
        
    }
    
    @IBAction func menuClicked4(_ sender: UIButton) {
        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Web") as! Web
        vc.titleString = "ข้อมูลเพิ่มเติม"
        vc.webUrlString = "\(HTTPHeaders.websiteURL)credit-information"
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func seeAllClicked1(_ sender: UIButton) {
        let vc = UIStoryboard.creditStoryBoard.instantiateViewController(withIdentifier: "CreditList") as! CreditList
        vc.typeID = assessmentJSON![0]["type_id"].stringValue//"1"
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func seeAllClicked2(_ sender: UIButton) {
        let vc = UIStoryboard.creditStoryBoard.instantiateViewController(withIdentifier: "CreditList") as! CreditList
        vc.typeID = activityJSON![0]["type_id"].stringValue//"2"
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func seeAllClicked3(_ sender: UIButton) {
        let vc = UIStoryboard.creditStoryBoard.instantiateViewController(withIdentifier: "CreditList") as! CreditList
        vc.typeID = specialJSON![0]["type_id"].stringValue//"3"
        self.navigationController!.pushViewController(vc, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension Credit_2: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView == assessmentCollectionView && assessmentJSON != nil {
            return assessmentJSON!.count
        }
        else if collectionView == activityCollectionView && activityJSON != nil {
            return activityJSON!.count
        }
        else if collectionView == specialCollectionView && specialJSON != nil {
            return specialJSON!.count
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == assessmentCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"assessmentCell", for: indexPath) as! CreditCell
            
            let cellArray = assessmentJSON![indexPath.item]

            //cell.setRoundAndShadow()
            cell.cellImage.sd_setImage(with: URL(string:cellArray["image_cover"].stringValue), placeholderImage: nil)
            
            cell.cellTitle.text = cellArray["title"].stringValue
            
            cell.cellTitle2.text = cellArray["type_text"].stringValue
            cell.cellDesc2.text = cellArray["type_name"].stringValue
            
            cell.cellTitle3.text = cellArray["point_text"].stringValue
            
            return cell
        }
        else if collectionView == activityCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityCell", for: indexPath) as! CreditCell
            
            let cellArray = activityJSON![indexPath.item]

            //cell.setRoundAndShadow()
            cell.cellImage.sd_setImage(with: URL(string:cellArray["image_cover"].stringValue), placeholderImage: nil)
            
            cell.cellTitle.text = cellArray["title"].stringValue
            cell.cellTitle2.text = cellArray["point_text"].stringValue
            
            return cell
        }
        else if collectionView == specialCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"specialCell", for: indexPath) as! CreditCell
            
            let cellArray = specialJSON![indexPath.item]

            //cell.setRoundAndShadow()
            cell.cellImage.sd_setImage(with: URL(string:cellArray["image_cover"].stringValue), placeholderImage: nil)
            
            cell.cellTitle.text = cellArray["title"].stringValue
            
            cell.cellTitle2.text = cellArray["type_text"].stringValue
            cell.cellDesc2.text = cellArray["type_name"].stringValue
            
            cell.cellTitle3.text = cellArray["point_text"].stringValue
            
            return cell
        }
        else {
            return UICollectionViewCell()
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension Credit_2: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == assessmentCollectionView {
            return CGSize(width: 350 , height: 152)
        }
        else if collectionView == activityCollectionView {
            return CGSize(width: 152 , height: 288)
        }
        else if collectionView == specialCollectionView {
            return CGSize(width: 350 , height: 152)
        }
        else {
            return CGSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == assessmentCollectionView {
            return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) //.zero
        }
        else if collectionView == activityCollectionView {
            return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) //.zero
        }
        else if collectionView == specialCollectionView {
            return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) //.zero
        }
        else {
            return UIEdgeInsets()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == assessmentCollectionView {
            return 15
        }
        else if collectionView == activityCollectionView {
            return 15
        }
        else if collectionView == specialCollectionView {
            return 15
        }
        else {
            return CGFloat()
        }
    }
}

// MARK: - UICollectionViewDelegate

extension Credit_2: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let vc = UIStoryboard.creditStoryBoard.instantiateViewController(withIdentifier: "CreditDetail") as! CreditDetail
        
        if collectionView == assessmentCollectionView {
            let cellArray = self.assessmentJSON![indexPath.item]
            //vc.creditMode = .assessment
            vc.creditID = cellArray["id"].stringValue
        }
        else if collectionView == activityCollectionView {
            let cellArray = self.activityJSON![indexPath.item]
            //vc.creditMode = .activity
            vc.creditID = cellArray["id"].stringValue
        }
        else if collectionView == specialCollectionView {
            let cellArray = self.specialJSON![indexPath.item]
            //vc.creditMode = .special
            vc.creditID = cellArray["id"].stringValue
        }
        self.navigationController!.pushViewController(vc, animated: true)
    }
}
