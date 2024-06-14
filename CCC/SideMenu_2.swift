//
//  SideMenu_2.swift
//  CCC
//
//  Created by Truk Karawawattana on 20/2/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SDWebImage

class SideMenu_2: UIViewController {
    
    var menuJSON: JSON?
    
    @IBOutlet var sideMenuTableView: UITableView!
    @IBOutlet weak var cccIDLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (menuJSON == nil) || SceneDelegate.GlobalVariables.reloadSideMenu {
            loadSideMenu()
            SceneDelegate.GlobalVariables.reloadSideMenu = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("SIDE MENU 2")
        
        // TableView
        self.sideMenuTableView.delegate = self
        self.sideMenuTableView.dataSource = self
        self.sideMenuTableView.backgroundColor = .clear
        self.sideMenuTableView.separatorStyle = .none

        // Update TableView with the data
        self.sideMenuTableView.reloadData()
        
        cccIDLabel.text = "CCC ID: \(SceneDelegate.GlobalVariables.userID)"
        versionLabel.text = "iOS Version \(Bundle.main.appVersionLong)"//(\(Bundle.main.appBuild))"
        
        //loadSideMenu()
    }
    
    func loadSideMenu() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "os_system":"iOS"
        ]
        loadRequest_V2(method:.get, apiName:"menus", authorization:true, showLoadingHUD:false, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS SIDEMENU\(json)")
                
                self.menuJSON = json["data"]
                self.sideMenuTableView.reloadData()
            }
        }
    }
    
    func selectDefaultMenu(rowNo:Int) {
        DispatchQueue.main.async {
            let defaultRow = IndexPath(row:rowNo, section: 0)
            self.sideMenuTableView.selectRow(at: defaultRow, animated: false, scrollPosition: .none)
            
            let cell = (self.sideMenuTableView.cellForRow(at: defaultRow) as? SideMenuCell)!
            cell.menuImage.setImageColor(color: .themeColor)
            cell.menuTitle.textColor = .themeColor
        }
    }
}//end ViewController

// MARK: - UITableViewDataSource

extension SideMenu_2: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (menuJSON != nil) {
            return menuJSON!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height >= 1792 {//iPhone 11 and upper
            return 55
        }
        else{//lower
            return 45
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
        
        let cellArray = menuJSON![indexPath.row]

        cell.menuImage.sd_setImage(with: URL(string:cellArray["menu_icon"].stringValue), placeholderImage: nil)
        //cell.menuImage.setImageColor(color: .themeColor)
        
        cell.menuTitle.text = cellArray["menu_title"].stringValue
        
        //cell.menuAlert.layer.cornerRadius = cell.menuAlert.frame.size.height/2
        //cell.menuAlert.layer.masksToBounds = true
        
        
        // Highlighted color
        let myHighlight = UIView()
        myHighlight.backgroundColor = .themeColor
        myHighlight.backgroundColor = myHighlight.backgroundColor!.withAlphaComponent(0.2)
        myHighlight.layer.cornerRadius = 25
        cell.selectedBackgroundView = myHighlight
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SideMenu_2: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.row)")
        
        let cellArray = menuJSON![indexPath.row]
        
        switch cellArray["menu_key"].stringValue {
        case "menu_history":
            let vc = UIStoryboard.historyStoryBoard.instantiateViewController(withIdentifier: "History") as! History
            self.navigationController!.pushViewController(vc, animated: true)
            self.sideMenuController!.hideMenu()
        
        case "menu_manual_exercise":
            let vc = UIStoryboard.manualStoryBoard.instantiateViewController(withIdentifier: "ManualList") as! ManualList
            self.navigationController!.pushViewController(vc, animated: true)
            self.sideMenuController!.hideMenu()
            
        case "menu_parkrun":
            let vc = UIStoryboard.historyStoryBoard.instantiateViewController(withIdentifier: "Parkrun") as! Parkrun
            self.navigationController!.pushViewController(vc, animated: true)
            self.sideMenuController!.hideMenu()
            
//        case "menu_create_challenge":
          
//        case "menu_campaign":
        
        case "menu_settings":
            let vc = UIStoryboard.settingStoryBoard.instantiateViewController(withIdentifier: "Setting") as! Setting
            self.navigationController!.pushViewController(vc, animated: true)
            self.sideMenuController!.hideMenu()
            
        case "menu_settings_account":
            let vc = UIStoryboard.settingStoryBoard.instantiateViewController(withIdentifier: "Setting_Account") as! Setting_Account
            self.navigationController!.pushViewController(vc, animated: true)
            self.sideMenuController!.hideMenu()
            
//        case "menu_manual":
            
        case "menu_logout":
            logOut()
            
        default:
            let urlStr = cellArray["menu_url"].stringValue
            if urlStr != "" {
                if urlStr.contains("http") {
                    let vc = UIStoryboard.mainStoryBoard_2.instantiateViewController(withIdentifier: "Web") as! Web
                    vc.titleString = cellArray["menu_title"].stringValue
                    vc.webUrlString = urlStr
                    self.navigationController!.pushViewController(vc, animated: true)
                }
                else {
                    if let url = URL(string: urlStr) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                        else {
                            showErrorNoData()
                        }
                    }
                }
                
                self.sideMenuController!.hideMenu()
            }
            else {
                showComingSoon()
            }
        }
    }
}

