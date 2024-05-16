//
//  Parkrun.swift
//  CCC
//
//  Created by Truk Karawawattana on 14/9/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Parchment

class Parkrun: UIViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("PARKRUN")
        
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []

        // Create variables for all view controllers you want to put in the
        // page menu, initialize them, and add each to the controller array.
        // (Can be any UIViewController subclass)
        // Make sure the title property of all view controllers is set
        // Example:
        let vc1 = UIStoryboard.historyStoryBoard.instantiateViewController(withIdentifier: "ParkrunHistory") as! ParkrunHistory
        vc1.title = "ส่งผลแข่งขัน"
        vc1.parkrunMode = .history
        controllerArray.append(vc1)
        
        let vc2 = UIStoryboard.historyStoryBoard.instantiateViewController(withIdentifier: "ParkrunHistory") as! ParkrunHistory
        vc2.title = "ประวัติการส่งผล"
        vc2.parkrunMode = .added
        controllerArray.append(vc2)

        let pagingViewController = PagingViewController(viewControllers: [
            vc1,
            vc2
        ])
        
        pagingViewController.delegate = self
        pagingViewController.backgroundColor = .white
        pagingViewController.menuItemSize = .sizeToFit(minWidth: 0, height: 50)
        pagingViewController.indicatorColor = .buttonRed
        pagingViewController.textColor = .textDarkGray
        pagingViewController.selectedTextColor = .themeColor
        pagingViewController.font = .Prompt_Regular(ofSize: 15)
        pagingViewController.selectedFont = .Prompt_Medium(ofSize: 15)
        
        let insets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
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
    
    @IBAction func back(_ sender: UIButton) {
            self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - PagingViewControllerDelegate

extension Parkrun: PagingViewControllerDelegate {
    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        
        view.endEditing(true)
    }
}
