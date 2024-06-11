//
//  ChallengeCreate.swift
//  CCC
//
//  Created by Truk Karawawattana on 24/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import AVFoundation
import Photos

class ChallengeCreate: UIViewController, UITextFieldDelegate {
    
    var challengeMode: ChallengeMode?
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var coverPic: UIImageView!
    @IBOutlet weak var coverBtn: UIButton!
    @IBOutlet weak var coverTitle: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CHALLENGE CREATE")
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        myScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        if challengeMode == .create {
            headerView.isHidden = true
            submitBtn.setTitle("สร้าง", for: .normal)
        }
        else if challengeMode == .edit {
            headerView.isHidden = false
            submitBtn.setTitle("แก้ไข", for: .normal)
        }
        
        coverDisplay(isCoverDisplay: false)
    }
    
    func coverDisplay(isCoverDisplay:Bool) {
        if isCoverDisplay {
            coverBtn.isHidden = true
            coverTitle.isHidden = true
        }
        else{
            coverBtn.isHidden = false
            coverTitle.isHidden = false
        }
    }
    
    func chooseImageSource()
    {
        DispatchQueue.main.async {
            AttachmentHandler.shared.showAttachmentActionSheet(vc: self, allowEdit: true)
            AttachmentHandler.shared.imagePickedBlock = { (image) in
                self.coverPic.image = image
                self.coverDisplay(isCoverDisplay: true)
            }
        }
    }
    
    @IBAction func cameraClick(_ sender: UIButton) {
        chooseImageSource()
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeDetail") as! ChallengeDetail
        vc.challengeMode = .create
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
