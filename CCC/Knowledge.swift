//
//  Knowledge.swift
//  CCC
//
//  Created by Truk Karawawattana on 14/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Parchment

class Knowledge: UIViewController {
    
    var knowledgeJSON : JSON?
    
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("KNOWLEDGE")
        
//        var controllerArray : [UIViewController] = []
//
//        let vc1 = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "KnowledgeList") as! KnowledgeList
//        vc1.title = "ทั้งหมด"
//        vc1.knowledgeMode = .all
//        controllerArray.append(vc1)
//
//        let vc2 = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "KnowledgeList") as! KnowledgeList
//        vc2.title = "เทคนิคการวิ่ง"
//        vc2.knowledgeMode = .technique
//        controllerArray.append(vc2)
//
//        let vc3 = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "KnowledgeList") as! KnowledgeList
//        vc3.title = "รายการวิ่ง"
//        vc3.knowledgeMode = .event
//        controllerArray.append(vc3)
//
//        let pagingViewController = PagingViewController(viewControllers: [
//            vc1,
//            vc2,
//            vc3
//        ])
//
//        pagingViewController.backgroundColor = .white
//        pagingViewController.menuItemSize = .sizeToFit(minWidth: 0, height: 50)//.selfSizing(estimatedWidth: 100, height: 50)
//
//        pagingViewController.indicatorColor = .buttonRed
//        pagingViewController.textColor = .textDarkGray
//        pagingViewController.selectedTextColor = .themeColor
//        pagingViewController.font = .Prompt_Regular(ofSize: 15)
//        pagingViewController.selectedFont = .Prompt_Regular(ofSize: 15)
//
//        let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//        pagingViewController.indicatorOptions = .visible(height: 4, zIndex: Int.max, spacing: insets, insets: .zero)
//        let borderInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        pagingViewController.borderOptions = .visible(height: 1, zIndex: Int.max-1, insets: borderInsets)
//
//        addChild(pagingViewController)
//        bottomView.addSubview(pagingViewController.view)
//        pagingViewController.didMove(toParent: self)
//        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//          pagingViewController.view.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
//          pagingViewController.view.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
//          pagingViewController.view.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
//          pagingViewController.view.topAnchor.constraint(equalTo: bottomView.topAnchor)
//        ])
        
        loadKnowledgeType()
    }
    
    func loadKnowledgeType() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"blog/blogType", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS KNOWLEDGE TYPE\(json)")
                
                self.knowledgeJSON = json["data"]
                if self.knowledgeJSON!.count > 0
                {
                    self.setupSlide()
                }
                else{
                    self.showErrorNoData()
                }
            }
        }
    }
    
    func setupSlide() {
        var controllerArray : [UIViewController] = []

        for i in 0..<knowledgeJSON!.count{
            let cellArray = knowledgeJSON![i]
            let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "KnowledgeList") as! KnowledgeList
            vc.title = cellArray["type_name"].stringValue
            vc.knowledgeID = cellArray["type_id"].stringValue
            controllerArray.append(vc)
        }

        let pagingViewController = PagingViewController(viewControllers:controllerArray)
        
        pagingViewController.backgroundColor = .white
        if knowledgeJSON!.count > 3 {
            pagingViewController.menuItemSize = .sizeToFit(minWidth: self.view.frame.width/3.5, height: 50)//.selfSizing(estimatedWidth: 100, height: 50)
        }
        else{
            pagingViewController.menuItemSize = .sizeToFit(minWidth: 0, height: 50)//.selfSizing(estimatedWidth: 100, height: 50)
        }

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

