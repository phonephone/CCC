//
//  SideMenu.swift
//  CCC
//
//  Created by Truk Karawawattana on 12/12/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

enum MenuID {
    case history
    case manual_input
    case parkrun
    case setting
    case document
    case logout
}

struct Menu {
    let menuID: MenuID
    let title: String
    let imgName: String
}

class SideMenu: UIViewController {
    
    var parkrunStatus:Bool?
    
    @IBOutlet var sideMenuTableView: UITableView!
    @IBOutlet weak var cccIDLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    var menus = [
        Menu(menuID: .history, title: "ประวัติการออกกำลังกาย", imgName: "menu_history"),
        Menu(menuID: .manual_input, title: "ส่งผลแบบกรอกเอง", imgName: "menu_manual"),
        //Menu(menuID: .parkrun, title: "ส่งผล Park Run Anywhere", imgName: "menu_parkrun"),
        Menu(menuID: .setting, title: "การตั้งค่า", imgName: "menu_setting"),
        Menu(menuID: .document, title: "คู่มือการใช้งาน", imgName: "menu_doc"),
        Menu(menuID: .logout, title: "ออกจากระบบ", imgName: "menu_logout"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("SIDE MENU")
        
        // TableView
        self.sideMenuTableView.delegate = self
        self.sideMenuTableView.dataSource = self
        self.sideMenuTableView.backgroundColor = .clear
        self.sideMenuTableView.separatorStyle = .none

        // Update TableView with the data
        self.sideMenuTableView.reloadData()
        
        cccIDLabel.text = "CCC ID: \(SceneDelegate.GlobalVariables.userID)"
        versionLabel.text = "Version (\(Bundle.main.appVersionLong))"//(\(Bundle.main.appBuild))"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //checkParkRunStatus()
        updateMenu()
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
    
//    func checkParkRunStatus() {
//        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID]
//        loadRequest(method:.post, apiName:"connect/parkrun/user/status_connect/", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                ProgressHUD.dismiss()
//
//            case .success(let responseObject):
//                let json = JSON(responseObject)
//                //print("SUCCESS PARKRUN STATUS\(json)")
//                
//                self.parkrunStatus = json["data"]["parkrunstatus"].boolValue
//                self.updateMenu()
//            }
//        }
//    }
    
    func updateMenu() {
        parkrunStatus = SceneDelegate.GlobalVariables.profileJSON!["parkrunstatus"].boolValue
        let found = menus.filter{$0.menuID == .parkrun}.count > 0
        
        if parkrunStatus == found {
            //menus.remove(at: 2)
        } else {
            if found {
                menus.remove(at: 2)
            } else{
                menus.insert(Menu(menuID: .parkrun, title: "ส่งผล Park Run Anywhere", imgName: "menu_parkrun"), at: 2)
            }
        }
        self.sideMenuTableView.reloadData()
    }
    
}//end ViewController

// MARK: - UITableViewDataSource

extension SideMenu: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
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

        //cell.menuImage.sd_setImage(with: URL(string:self.menuJSON![indexPath.row]["menu_image_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        //cell.menuImage.setImageColor(color: .themeColor)
        
        cell.menuTitle.text = menus[indexPath.row].title
        cell.menuImage.image = UIImage(named: menus[indexPath.row].imgName)
        
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

extension SideMenu: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.row)")
        
        switch menus[indexPath.item].menuID {
        case .history:
            let vc = UIStoryboard.historyStoryBoard.instantiateViewController(withIdentifier: "History") as! History
            self.navigationController!.pushViewController(vc, animated: true)
            self.sideMenuController!.hideMenu()
        
        case .manual_input:
            let vc = UIStoryboard.manualStoryBoard.instantiateViewController(withIdentifier: "ManualList") as! ManualList
            self.navigationController!.pushViewController(vc, animated: true)
            self.sideMenuController!.hideMenu()
            
        case .parkrun:
            let vc = UIStoryboard.historyStoryBoard.instantiateViewController(withIdentifier: "Parkrun") as! Parkrun
            self.navigationController!.pushViewController(vc, animated: true)
            self.sideMenuController!.hideMenu()
        
        case .setting:
            let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Setting") as! Setting
            self.navigationController!.pushViewController(vc, animated: true)
            self.sideMenuController!.hideMenu()
            
        case .document:
            let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Web") as! Web
            vc.titleString = "คู่มือการใช้งาน"
            vc.webUrlString = "\(HTTPHeaders.websiteURL)home/content/5"
            self.navigationController!.pushViewController(vc, animated: true)
            self.sideMenuController!.hideMenu()
            
        case .logout:
            logOut()
        }
    }
}
