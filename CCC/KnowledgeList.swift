//
//  KnowledgeList.swift
//  CCC
//
//  Created by Truk Karawawattana on 14/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class KnowledgeList: UIViewController {
    
    var knowledgeID : String?
    
    var knowledgeJSON : JSON?
    
    @IBOutlet weak var myTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("KNOWLEDGE LIST \(knowledgeID!)")
        
        // TableView
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.myTableView.backgroundColor = .clear
        //self.myTableView.tableFooterView = UIView(frame: .zero)
        self.myTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.myTableView.frame.size.width, height: 1))
        self.myTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        loadKnowledgeList()
    }
    
    func loadKnowledgeList() {
        let parameters:Parameters = ["type_id":knowledgeID!]
        loadRequest(method:.post, apiName:"blog/blogList", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS KNOWLEDGE LIST\(json)")
                
                self.knowledgeJSON = json["data"]
                self.myTableView.reloadData()
                
                ProgressHUD.dismiss()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension KnowledgeList: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (knowledgeJSON != nil) {
            return knowledgeJSON!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250//self.myTableView.frame.height/6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KnowledgeCell", for: indexPath) as! KnowledgeCell
        
        let cellArray = knowledgeJSON![indexPath.item]
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["cover_img"].stringValue), placeholderImage: UIImage(named: "logo"))
        
        let attrs1 = [NSAttributedString.Key.font : UIFont.Prompt_Bold(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.white]

            let attrs2 = [NSAttributedString.Key.font : UIFont.Prompt_Regular(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.white]

            let attributedString1 = NSMutableAttributedString(string:"\(cellArray["title"].stringValue)\n", attributes:attrs1)

            let attributedString2 = NSMutableAttributedString(string:cellArray["description"].stringValue, attributes:attrs2)

            attributedString1.append(attributedString2)
        cell.cellTitle.attributedText = attributedString1
        
        //cell.cellTitle.text = cellArray["title"].stringValue
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension KnowledgeList: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellArray = knowledgeJSON![indexPath.item]
        
        let vc = UIStoryboard.mainStoryBoard_2.instantiateViewController(withIdentifier: "Web") as! Web
        //vc.titleString = "Announcement"
        vc.webUrlString = cellArray["url"].stringValue
        self.navigationController!.pushViewController(vc, animated: true)
    }
}
