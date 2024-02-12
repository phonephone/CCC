//
//  Challenge.swift
//  CCC
//
//  Created by Truk Karawawattana on 11/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Parchment

class Challenge: UIViewController {
    
    var rankingAllJSON : JSON?
    var rankingWeekJSON : JSON?
    
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CHALLENGE")
        
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []

        // Create variables for all view controllers you want to put in the
        // page menu, initialize them, and add each to the controller array.
        // (Can be any UIViewController subclass)
        // Make sure the title property of all view controllers is set
        // Example:
        let vc1 = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeList_2") as! ChallengeList_2
        vc1.title = "รายการแข่งขัน"
        vc1.challengeMode = .all
        controllerArray.append(vc1)
        
        let vc2 = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeList_2") as! ChallengeList_2
        vc2.title = "รายการที่เข้าร่วม"
        vc2.challengeMode = .joined
        controllerArray.append(vc2)
        
//        let vc3 = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "ChallengeCreate") as! ChallengeCreate
//        vc3.title = "สร้างการแข่งขัน"
//        vc3.challengeMode = .create
//        controllerArray.append(vc3)

        let pagingViewController = PagingViewController(viewControllers: controllerArray)
        
        pagingViewController.backgroundColor = .white
        pagingViewController.menuItemSize = .sizeToFit(minWidth: self.view.frame.width/2, height: 50)

        pagingViewController.indicatorColor = .buttonRed
        pagingViewController.textColor = .textDarkGray
        pagingViewController.selectedTextColor = .themeColor
        pagingViewController.font = .Prompt_Regular(ofSize: 15)
        pagingViewController.selectedFont = .Prompt_Regular(ofSize: 15)
        
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        pagingViewController.indicatorOptions = .visible(height: 4, zIndex: Int.max, spacing: insets, insets: .zero)
        let borderInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pagingViewController.borderOptions = .visible(height: 1, zIndex: Int.max-1, insets: borderInsets)
        
        addChild(pagingViewController)
        bottomView.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
          pagingViewController.view.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
          pagingViewController.view.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
          pagingViewController.view.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
          pagingViewController.view.topAnchor.constraint(equalTo: bottomView.topAnchor)
        ])
    }
    
    @IBAction func leftMenuShow(_ sender: UIButton) {
        self.sideMenuController!.revealMenu()
    }
}

// MARK: - PagingViewControllerDelegate

extension Challenge: PagingViewControllerDelegate {
    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        
        view.endEditing(true)
    }
}
