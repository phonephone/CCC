//
//  ChallengeList_2.swift
//  CCC
//
//  Created by Truk Karawawattana on 5/10/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SkeletonView

enum ChallengeMode {
    case all
    case joined
    case create
    case edit
}

enum MyMode {
    case official
    case general
}

class ChallengeList_2: UIViewController, UITextFieldDelegate {
    
    var challengeJSON : JSON?
    var allJSON : JSON?
    
    var provinceJSON:JSON?
    var amphurJSON:JSON?
    var tumbonJSON:JSON?
    
    var challengeMode: ChallengeMode?
    var myMode: MyMode = .official
    
    var firstTime = true
    
    var selectedProvinceID = ""
    var selectedAmphurID = ""
    var selectedTumbonID = ""
    
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var demographicView: UIView!
    @IBOutlet weak var provinceField: MyField!
    @IBOutlet weak var amphurField: MyField!
    @IBOutlet weak var tumbonField: MyField!
    @IBOutlet weak var tumbonView: UIView!
    
    @IBOutlet weak var provinceBtn: MyButton!
    @IBOutlet weak var amphurBtn: MyButton!
    @IBOutlet weak var tumbonBtn: MyButton!
    
    @IBOutlet weak var filterStack: UIStackView!
    @IBOutlet weak var officialBtn: UIButton!
    @IBOutlet weak var generalBtn: UIButton!
    
    @IBOutlet weak var myTableView: UITableView!
    
    var provincePicker: UIPickerView! = UIPickerView()
    var amphurPicker: UIPickerView! = UIPickerView()
    var tumbonPicker: UIPickerView! = UIPickerView()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if challengeMode == .all {
            if SceneDelegate.GlobalVariables.reloadChallengeAll {
                loadChallenge(showLoadingHUD: true)
                SceneDelegate.GlobalVariables.reloadChallengeAll = false
            }
        }
        else if challengeMode == .joined {
            if SceneDelegate.GlobalVariables.reloadChallengeJoin {
                loadChallenge(showLoadingHUD: true)
                SceneDelegate.GlobalVariables.reloadChallengeJoin = false
            }
        }
        
        searchField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CHALLENGE LIST \(challengeMode!)")
        
        // TableView
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.backgroundColor = .clear
        //self.myTableView.tableFooterView = UIView(frame: .zero)
        myTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.frame.size.width, height: 1))
        myTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        myTableView.isUserInteractionEnabled = false
        
        if challengeMode == .all {
            demographicView.isHidden = false
            filterStack.isHidden = true
        }
        else if challengeMode == .joined {
            demographicView.isHidden = true
            filterStack.isHidden = false
        }
        
        setupField(field: provinceField)
        setupField(field: amphurField)
        setupField(field: tumbonField)
        
        pickerSetup(picker: provincePicker)
        provinceField.inputView = provincePicker
        
        pickerSetup(picker: amphurPicker)
        amphurField.inputView = amphurPicker
        amphurField.isEnabled = false
        amphurBtn.isEnabled = false
        
        pickerSetup(picker: tumbonPicker)
        tumbonField.inputView = tumbonPicker
        tumbonField.isEnabled = false
        tumbonBtn.isEnabled = false
        
        loadProvince()
    }
    
    func loadChallenge(showLoadingHUD:Bool) {
        var url:String = ""
        
        var parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "search":searchField.text ?? "",
                                     "province":selectedProvinceID,
                                     "amphure":selectedAmphurID,
                                     "sub_district":selectedTumbonID
                                     
        ]
        print(parameters)
        
        if challengeMode == .all {
            url = "challenges/list"
        }
        else if challengeMode == .joined {
            url = "challenges/my"
            
            if myMode == .official {
                parameters.updateValue("official", forKey: "filter")
            }
            else if myMode == .general {
                parameters.updateValue("general", forKey: "filter")
            }
        }
        
        loadRequest_V2(method:.post, apiName:url, authorization:true, showLoadingHUD:showLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS CHALLENGE LIST\(json)")
                
                self.allJSON = json["data"]
                self.challengeJSON = self.allJSON
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.00) {
                    self.myTableView.reloadData()
                    self.myTableView.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    func loadProvince() {
        let parameters:Parameters = [:]
        print(parameters)
        loadRequest_V2(method:.get, apiName:"provinces", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS PROVINCE\(json)")
                
                self.provinceJSON = json["data"]
                self.provincePicker.reloadAllComponents()
            }
        }
    }
    
    func loadAmphur(inProvinceID:String) {
        tumbonField.isEnabled = false
        tumbonBtn.isEnabled = false
        
        let parameters:Parameters = ["id_provinces":inProvinceID]
        print(parameters)
        loadRequest_V2(method:.get, apiName:"amphures", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS AMPHUR\(json)")
                
                self.amphurJSON = json["data"]
                self.amphurPicker.reloadAllComponents()
                self.amphurField.isEnabled = true
                self.amphurBtn.isEnabled = true
            }
        }
    }
    
    func loadTumbon(inAumphurID:String) {
        let parameters:Parameters = ["id_amphures":inAumphurID]
        print(parameters)
        loadRequest_V2(method:.get, apiName:"subDistricts", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS TUMBON\(json)")
                
                self.tumbonJSON = json["data"]
                self.tumbonPicker.reloadAllComponents()
                self.tumbonField.isEnabled = true
                self.tumbonBtn.isEnabled = true
            }
        }
    }
    
    func pickerSetup(picker:UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
    }
    
    // MARK: - textField
    func setupField(field:UITextField) {
        field.delegate = self
        field.returnKeyType = .next
        field.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == provinceField && provinceField.text == "" {
            selectPicker(provincePicker, didSelectRow: 0)
        }
        else if textField == amphurField && amphurField.text == "" {
            selectPicker(amphurPicker, didSelectRow: 0)
            amphurPicker.selectRow(0, inComponent: 0, animated: false)
        }
        else if textField == tumbonField && tumbonField.text == "" {
            selectPicker(tumbonPicker, didSelectRow: 0)
            tumbonPicker.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchField {
            searchField.resignFirstResponder()
            return true
        }
        else {
            return false
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        //filterJSON(searchText: textField.text!)
        
        if textField == searchField {
            loadChallenge(showLoadingHUD: true)
        }
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
    
    @IBAction func demographicClick(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            provinceField.becomeFirstResponder()
            
        case 2:
            amphurField.becomeFirstResponder()
            
        case 3:
            tumbonField.becomeFirstResponder()
            
        default:
            break
        }
    }
    
    @IBAction func filterClick(_ sender: UIButton) {
        officialBtn.titleLabel?.font = .Prompt_Regular(ofSize: 16)
        generalBtn.titleLabel?.font = .Prompt_Regular(ofSize: 16)
        
        officialBtn.setTitleColor(.textGray2, for: .normal)
        generalBtn.setTitleColor(.textGray2, for: .normal)
        
        if sender.tag == 1 {//official
            officialBtn.titleLabel?.font = .Prompt_SemiBold(ofSize: 16)
            officialBtn.setTitleColor(.themeColor, for: .normal)
            myMode = .official
        }
        else if sender.tag == 2 {//general
            generalBtn.titleLabel?.font = .Prompt_SemiBold(ofSize: 16)
            generalBtn.setTitleColor(.themeColor, for: .normal)
            myMode = .general
        }
        loadChallenge(showLoadingHUD: true)
    }
}


// MARK: - UITableViewDataSource

extension ChallengeList_2: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (challengeJSON != nil) {
            return challengeJSON!.count
        }
        else{
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeCell", for: indexPath) as! ChallengeCell
        
        if challengeJSON != nil {
            let cellArray = self.challengeJSON![indexPath.item]
            
            cell.cellImage.sd_setImage(with: URL(string:cellArray["cover_img"].stringValue), placeholderImage: UIImage(named: "icon_1024"))
            cell.cellName.text = "\(cellArray["competition_name"].stringValue)"
            //cell.cellName.text = "\(cellArray["competition_name"].stringValue)\n\(cellArray["description"].stringValue)"
            cell.cellDate.text = "\(cellArray["start_date"].stringValue) - \(cellArray["end_date"].stringValue)"
            
            let typeArray = cellArray["type_activity"]
            cell.cellType.arrangedSubviews.forEach {//Clear stack
                $0.removeFromSuperview()
            }
            if typeArray.isEmpty {
                cell.cellType.isHidden = true
            }
            else {
                for i in 0...typeArray.count {
                    if typeArray[i]["act_type"] == "text" {
                        let label = UILabel()
                        label.text = typeArray[i]["act_name_th"].stringValue
                        label.textColor = .textGray1
                        label.font = .Prompt_SemiBold(ofSize: 13)
                        cell.cellType.addArrangedSubview(label)
                        cell.cellType.isHidden = false
                    }
                    else {
                        let imageView = UIImageView()
                        imageView.contentMode = .scaleAspectFit
                        //imageView.image = UIImage(named: "icon_run")
                        imageView.sd_setImage(with: URL(string:typeArray[i]["act_icon_name"].stringValue))
                        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0/1.0).isActive = true
                        imageView.heightAnchor.constraint(equalToConstant: CGFloat(0)).isActive = false
                        cell.cellType.addArrangedSubview(imageView)
                        cell.cellType.isHidden = false
                    }
                }
            }
            cell.cellGroup.text = cellArray["status_text"].stringValue
            cell.cellGroup.backgroundColor = colorFromHex(hexString: cellArray["status_background"].stringValue)
            cell.cellCompetitor.text = "จำนวนผู้เข้าร่วม \(cellArray["number_challenge_participant"].stringValue) คน"
            
            cell.hideAnimation()
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChallengeList_2: UITableViewDelegate {
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


// MARK: - SkeletonTableViewDataSource

extension ChallengeList_2: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "ChallengeCell"
    }
}


// MARK: - Picker Datasource
extension ChallengeList_2: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == provincePicker && provinceJSON != nil {
            return provinceJSON!.count
        }
        else if pickerView == amphurPicker && amphurJSON != nil {
            return amphurJSON!.count
        }
        else if pickerView == tumbonPicker && tumbonJSON != nil {
            return tumbonJSON!.count
        }
        else{
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = .Prompt_Regular(ofSize: 20)
            pickerLabel?.textAlignment = .center
        }
        
        if pickerView == provincePicker && provinceJSON != nil {
            pickerLabel?.text = provinceJSON![row]["name_th_provinces"].stringValue
        }
        else if pickerView == amphurPicker && amphurJSON != nil {
            pickerLabel?.text = amphurJSON![row]["name_th_amphures"].stringValue
        }
        else if pickerView == tumbonPicker && tumbonJSON != nil {
            pickerLabel?.text = tumbonJSON![row]["name_th_districts"].stringValue
        }
        else{
            pickerLabel?.text = ""
        }

        pickerLabel?.textColor = .textDarkGray

        return pickerLabel!
    }
}

// MARK: - Picker Delegate
extension ChallengeList_2: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }

    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        
        if pickerView == provincePicker {
            provinceField.text = provinceJSON![row]["name_th_provinces"].stringValue
            selectedProvinceID = provinceJSON![row]["id_provinces"].stringValue
            
            selectedAmphurID = ""
            amphurField.text = ""
            
            selectedTumbonID = ""
            tumbonField.text = ""
            tumbonJSON = nil
            tumbonPicker.reloadAllComponents()
            
            loadAmphur(inProvinceID: selectedProvinceID)
        }
        else if pickerView == amphurPicker {
            amphurField.text = amphurJSON![row]["name_th_amphures"].stringValue
            selectedAmphurID = amphurJSON![row]["id_amphures"].stringValue
            
            selectedTumbonID = ""
            tumbonField.text = ""
            tumbonJSON = nil
            tumbonPicker.reloadAllComponents()
            
            loadTumbon(inAumphurID: selectedAmphurID)
        }
        else if pickerView == tumbonPicker {
            tumbonField.text = tumbonJSON![row]["name_th_districts"].stringValue
            selectedTumbonID = tumbonJSON![row]["id_districts"].stringValue
        }
        
        //print("จังหวัด \(selectedProvinceID)\nอำเภอ \(selectedAmphurID)\nตำบล \(selectedTumbonID)")
        loadChallenge(showLoadingHUD: true)
    }
}
