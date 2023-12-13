//
//  ChallengeList.swift
//  CCC
//
//  Created by Truk Karawawattana on 11/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

//enum ChallengeMode {
//    case all
//    case joined
//    case create
//    case edit
//}

class ChallengeList: UIViewController, UITextFieldDelegate {
    
    var challengeJSON : JSON?
    var allJSON : JSON?
    
    var challengeMode: ChallengeMode?
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var myTableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadChallenge(showLoadingHUD: true)
        searchField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CHALLENGE LIST \(challengeMode!)")
        
        // TableView
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        self.myTableView.backgroundColor = .clear
        //self.myTableView.tableFooterView = UIView(frame: .zero)
        self.myTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.myTableView.frame.size.width, height: 1))
        self.myTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    func loadChallenge(showLoadingHUD:Bool) {
        var parameters:Parameters = [:]
        if challengeMode == .all {
            parameters = ["all_id":SceneDelegate.GlobalVariables.userID,
                          "search":searchField.text ?? ""]
        }
        else if challengeMode == .joined {
            parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                          "search":searchField.text ?? ""]
        }
        
        loadRequest(method:.post, apiName:"challenges", authorization:true, showLoadingHUD:showLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS CHALLENGE LIST\(json)")
                
                self.allJSON = json["data"]
                self.challengeJSON = self.allJSON
                self.myTableView.reloadData()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.resignFirstResponder()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        //filterJSON(searchText: textField.text!)
        loadChallenge(showLoadingHUD: false)
    }
    
    func filterJSON(searchText:String) {
        if searchText == "" {
            self.challengeJSON = self.allJSON
        }
        else{
            let filteredJSON = self.allJSON!.arrayValue.filter({ (json) -> Bool in
                return json["competition_name"].stringValue.containsIgnoringCase(searchText)||json["description"].stringValue.containsIgnoringCase(searchText)||json["start_date"].stringValue.containsIgnoringCase(searchText)||json["end_date"].stringValue.containsIgnoringCase(searchText);
            })
            self.challengeJSON = JSON(filteredJSON)
            
            /*
             self.directoryJSON = self.allJSON!.filter {item in
             if let itemId = item["id"] {
             return itemId != nil
             }
             return false
             }
             */
        }
        myTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension ChallengeList: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (challengeJSON != nil) {
            return challengeJSON!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130//self.myTableView.frame.height/6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellArray = self.challengeJSON![indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeCell", for: indexPath) as! ChallengeCell
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["cover_img"].stringValue), placeholderImage: UIImage(named: "icon_1024"))
        cell.cellName.text = "\(cellArray["competition_name"].stringValue)"
        //cell.cellName.text = "\(cellArray["competition_name"].stringValue)\n\(cellArray["description"].stringValue)"
        cell.cellDate.text = "\(cellArray["start_date"].stringValue) - \(cellArray["end_date"].stringValue)"
        cell.cellCompetitor.text = "จำนวนผู้เข้าร่วม \(cellArray["number_challenge_participant"].stringValue) คน"
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChallengeList: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellArray = self.challengeJSON![indexPath.item]
        
        if cellArray["status_join"] == "unjoin" {
            let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeDetail_2") as! ChallengeDetail_2
            vc.challengeMode = .all
            vc.challengeID = cellArray["challenge_id"].stringValue
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else {
            let vc = UIStoryboard.challengeStoryBoard.instantiateViewController(withIdentifier: "ChallengeJoin_2") as! ChallengeJoin_2
            vc.challengeMode = .joined
            vc.challengeID = cellArray["challenge_id"].stringValue
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
}
