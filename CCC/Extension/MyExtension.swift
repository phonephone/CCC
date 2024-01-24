//
//  RoundRect.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 3/11/2564 BE.
//

import Foundation
import UIKit
import Alamofire
import ProgressHUD
import SideMenuSwift
import SwiftyJSON

extension HTTPHeaders {
    //static let websiteURL = "https://softapi.tmadigital.com/"
    //static let websiteURL = "https://caloriescredit.tmadigital.com/"
    static let websiteURL = "https://ccc.mots.go.th/"
    
    static let baseURL = "\(websiteURL)apiapp/"
    static let baseURL_V2 = "\(websiteURL)apiapp/v_2/"
    
    static let headerWithAuthorize = ["Authorization": PlistParser.getKeysValue()!["apiBearer"]!, "Accept": "application/json"] as HTTPHeaders
    
    //static let headerWithAuthorize = ["Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.IlRNQV9jYWxvcmllc2NyZWRpdF9jY2Nfc2Vzc2lvbl8yMDIyIg.XgqYWQw8nIX0xKWgAamqJuUZ--Mibu8kyNgTJz7wHP0", "Accept": "application/json"] as HTTPHeaders
    
    static let header = ["Accept": "application/json"] as HTTPHeaders
}

// MARK: - Color & Font & Value
extension UIColor {
    static let themeColor = UIColor(named: "Main_Theme_1")!
    static let themeColor2 = UIColor(named: "Main_Theme_2")!
    static let themeBgColor = UIColor(named: "Bg_Theme_Light")!
    static let textDarkGray = UIColor(named: "Text_Dark_Gray")!
    static let textGray = UIColor(named: "Text_Gray")!
    static let textGray1 = UIColor(named: "Text_Gray_1")!
    static let textGray2 = UIColor(named: "Text_Gray_2")!
    static let textPointGold = UIColor(named: "Text_Point_Gold")!
    static let buttonRed = UIColor(named: "Btn_Red")!
    static let buttonGreen = UIColor(named: "Btn_Green")!
    static let buttonDisable = UIColor(named: "Btn_Disable")!
    static let tabSelected = UIColor(named: "Tab_Selected")!
}

extension UIFont {
    class func Prompt_Regular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Prompt-Regular", size: size)!
    }
    class func Prompt_Medium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Prompt-Medium", size: size)!
    }
    class func Prompt_SemiBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Prompt-SemiBold", size: size)!
    }
    class func Prompt_Bold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Prompt-Bold", size: size)!
    }
    
    class func Roboto_Regular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Regular", size: size)!
    }
    class func Roboto_Medium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Medium", size: size)!
    }
    class func Roboto_Bold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Bold", size: size)!
    }
    
    static let Alert_Title = UIFont(name: "Prompt-SemiBold", size: 16)!
    static let Alert_Message = UIFont(name: "Prompt-Regular", size: 14)!
    static let Alert_Button = UIFont(name: "Prompt-Medium", size: 16)!
}


// MARK: - UIStoryboard
extension UIStoryboard  {
    static let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    static let mainStoryBoard_2 = UIStoryboard(name: "Main_2", bundle: nil)
    static let loginStoryBoard = UIStoryboard(name: "Login", bundle: nil)
    static let runStoryBoard = UIStoryboard(name: "Run", bundle: nil)
    static let manualStoryBoard = UIStoryboard(name: "Manual", bundle: nil)
    static let historyStoryBoard = UIStoryboard(name: "History", bundle: nil)
    static let challengeStoryBoard = UIStoryboard(name: "Challenge", bundle: nil)
    static let creditStoryBoard = UIStoryboard(name: "Credit", bundle: nil)
}


// MARK: - Bundle
extension Bundle {
    public var appName: String { getInfo("CFBundleName")  }
    public var displayName: String {getInfo("CFBundleDisplayName")}
    public var language: String {getInfo("CFBundleDevelopmentRegion")}
    public var identifier: String {getInfo("CFBundleIdentifier")}
    public var copyright: String {getInfo("NSHumanReadableCopyright")}
    public var appBuild: String { getInfo("CFBundleVersion") }
    public var appVersionLong: String { getInfo("CFBundleShortVersionString") }
    public var appVersionShort: String { getInfo("CFBundleShortVersion") }
    
    fileprivate func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "⚠️" }
}

// MARK: - UINavigationController
extension UINavigationController {
    
    func setStatusBar(backgroundColor: UIColor) {
        var statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            let topPadding = window?.safeAreaInsets.top
            statusBarFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: topPadding ?? 0.0)
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = backgroundColor
        view.addSubview(statusBarView)
    }
    
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
    
    func removeAnyViewControllers(ofKind kind: AnyClass)
    {
        self.viewControllers = self.viewControllers.filter { !$0.isKind(of: kind)}
    }
    
    func containsViewController(ofKind kind: AnyClass) -> Bool
    {
        return self.viewControllers.contains(where: { $0.isKind(of: kind) })
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func embed(_ viewController:UIViewController, inView view:UIView){
        viewController.willMove(toParent: self)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }
    
    func unEmbed(_ viewController:UIViewController){
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        viewController.didMove(toParent: nil)
    }
    
    func switchToLogin() {
        let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Login")
        self.navigationController!.setViewControllers([vc], animated: true)
    }
    
    func switchToHome() {
        //let vc = UIStoryboard.init(name:"Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabBar")
        //self.navigationController!.setViewControllers([vc], animated: true)
        
        let menuViewController = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "SideMenu")
        let contentViewController = UIStoryboard.mainStoryBoard_2.instantiateViewController(withIdentifier: "TabBar_2")
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        SideMenuController.preferences.basic.menuWidth = screenSize.width*0.8
        SideMenuController.preferences.basic.position = .above
        SideMenuController.preferences.basic.direction = .left
        SideMenuController.preferences.basic.enablePanGesture = true
        SideMenuController.preferences.basic.supportedOrientations = .portrait
        SideMenuController.preferences.basic.shouldRespectLanguageDirection = true
        
        self.navigationController!.setViewControllers([SideMenuController(contentViewController: contentViewController, menuViewController: menuViewController)], animated: true)
    }
    
    func switchToError() {
        let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "ServerError")
        self.navigationController!.setViewControllers([vc], animated: true)
    }
    
    func logOut() {
        UserDefaults.standard.removeObject(forKey:"userID")
        self.switchToLogin()
    }
    
    func loadingHUD() {
        ProgressHUD.show("Loading", interaction: false)
    }
    
    func submitSuccess() {
        ProgressHUD.showSuccess("ข้อมูลถูกบันทึกเรียบร้อย")
    }
    
    func showErrorNoData() {
        ProgressHUD.showError("ไม่มีข้อมูล")
    }
    
    func showComingSoon() {
        ProgressHUD.imageError = UIImage(named:"coming_soon")!
        ProgressHUD.showError("Coming Soon")
    }
    
    func loadRequest(method:HTTPMethod, apiName:String, authorization:Bool, showLoadingHUD:Bool, dismissHUD:Bool, parameters:Parameters, completion: @escaping (AFResult<AnyObject>) -> Void) {
        
        if showLoadingHUD == true
        {
            loadingHUD()
        }
        
        let baseURL = HTTPHeaders.baseURL
        let fullURL = baseURL+apiName
        
        var headers: HTTPHeaders
        if authorization == true {
            //let accessToken = UserDefaults.standard.string(forKey:"access_token")
            headers = HTTPHeaders.headerWithAuthorize
        }
        else{
            headers = HTTPHeaders.header
        }
        //print("HEADER = \(headers)")
        //print("PARAM = \(parameters)")
        
        AF.request(fullURL,
                   method: method,
                   parameters: parameters,
                   //encoding: JSONEncoding.default,
                   headers: headers,
                   requestModifier: { $0.timeoutInterval = 60 }
        ).responseJSON { response in
            
            //debugPrint(response)
            
            switch response.result {
            case .success(let data as AnyObject):
                
                let json = JSON(data)
                if json["message"] == "success" {
                    if showLoadingHUD == true && dismissHUD == true
                    {
                        ProgressHUD.dismiss()
                    }
                    completion(.success(data))
                }
                else{
                    ProgressHUD.showError(json["message"].stringValue)
                    //ProgressHUD.showFailed(json["data"][0]["error"].stringValue)
                }
                
            case .failure(let error):
                completion(.failure(error))
                
            default:
                fatalError("received non-dictionary JSON response")
            }
        }
    }
    
    func loadRequest_V2(method:HTTPMethod, apiName:String, authorization:Bool, showLoadingHUD:Bool, dismissHUD:Bool, parameters:Parameters, completion: @escaping (AFResult<AnyObject>) -> Void) {
        
        if showLoadingHUD == true
        {
            loadingHUD()
        }
        
        let baseURL = HTTPHeaders.baseURL_V2
        let fullURL = baseURL+apiName
        
        var headers: HTTPHeaders
        if authorization == true {
            //let accessToken = UserDefaults.standard.string(forKey:"access_token")
            headers = HTTPHeaders.headerWithAuthorize
        }
        else{
            headers = HTTPHeaders.header
        }
        //print("HEADER = \(headers)")
        //print("PARAM = \(parameters)")
        
        AF.request(fullURL,
                   method: method,
                   parameters: parameters,
                   //encoding: JSONEncoding.default,
                   headers: headers,
                   requestModifier: { $0.timeoutInterval = 60 }
        ).responseJSON { response in
            
            //debugPrint(response)
            
            switch response.result {
            case .success(let data as AnyObject):
                
                let json = JSON(data)
                if json["message"] == "success" {
                    if showLoadingHUD == true && dismissHUD == true
                    {
                        ProgressHUD.dismiss()
                    }
                    completion(.success(data))
                }
                else{
                    ProgressHUD.showError(json["message"].stringValue)
                    //ProgressHUD.showFailed(json["data"][0]["error"].stringValue)
                }
                
            case .failure(let error):
                completion(.failure(error))
                
            default:
                fatalError("received non-dictionary JSON response")
            }
        }
    }
    
    @objc func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func blurViewSetup() -> UIVisualEffectView{
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView (effect: blurEffect)
        blurView.bounds = self.view.bounds
        blurView.center = self.view.center
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(blurViewTapped))
        blurView.isUserInteractionEnabled = true
        blurView.addGestureRecognizer(tap)
        
        return blurView
    }
    
    func popIn(popupView : UIView) {
        var backgroundView:UIView
        if let tabBarView = self.tabBarController?.view {
            backgroundView = tabBarView
        }
        else {
            backgroundView = self.view
        }
        
        //        let blurView = blurViewSetup()
        //        blurView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        //        blurView.alpha = 0
        //        backgroundView!.addSubview(blurView)
        
        //popupView.center = backgroundView!.center
        popupView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        popupView.alpha = 0
        
        backgroundView.addSubview(popupView)
        
        UIView.animate(withDuration: 0.3, animations:{
            //blurView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            //blurView.alpha = 1
            
            popupView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            popupView.alpha = 1
        })
    }
    
    func popOut(popupView : UIView) {
        UIView.animate(withDuration: 0.3, animations:{
            popupView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            popupView.alpha = 1
        }, completion: {_ in
            popupView.removeFromSuperview()
        })
    }
    
    @objc func blurViewTapped(_ sender: UITapGestureRecognizer) {
        //sender.view?.removeFromSuperview()
        print("Tap Blur")
    }
    
    func colorFromRGB(rgbString : String) -> UIColor{
        let rgbArray = rgbString.components(separatedBy: ",")
        
        if rgbArray.count == 3 {
            let red = Float(rgbArray[0])!
            let green = Float(rgbArray[1])!
            let blue = Float(rgbArray[2])!
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1.0)
            return color
        }
        else {
            return .textGray1
        }
    }
    
    func dateFromServerString(dateStr:String) -> Date? {
        if let dtDate = DateFormatter.serverFormatter.date(from: dateStr){
            return dtDate as Date?
        }
        return nil
    }
    
    func dateWithTimeFromServerString(dateStr:String) -> Date? {
        if let dtDate = DateFormatter.serverWihtTimeFormatter.date(from: dateStr){
            return dtDate as Date?
        }
        return nil
    }
    
    func dateToServerString(date:Date) -> String{
        let strdt = DateFormatter.serverFormatter.string(from: date)
        if let dtDate = DateFormatter.serverFormatter.date(from: strdt){
            return DateFormatter.serverFormatter.string(from: dtDate)
        }
        return "-"
    }
    
    func dateWithTimeToServerString(date:Date) -> String{
        let strdt = DateFormatter.serverWihtTimeFormatter.string(from: date)
        if let dtDate = DateFormatter.serverWihtTimeFormatter.date(from: strdt){
            return DateFormatter.serverWihtTimeFormatter.string(from: dtDate)
        }
        return "-"
    }
    
    func appDateFromString(dateStr:String, format:String) -> Date?{
        let dateFormatter:DateFormatter = DateFormatter.customFormatter
        dateFormatter.dateFormat = format
        if let dtDate = dateFormatter.date(from: dateStr){
            return dtDate as Date?
        }
        return nil
    }
    
    func appStringFromDate(date:Date, format:String) -> String{
        let dateFormatter:DateFormatter = DateFormatter.customFormatter
        dateFormatter.dateFormat = format
        let strdt = dateFormatter.string(from: date)
        if let dtDate = dateFormatter.date(from: strdt){
            return dateFormatter.string(from: dtDate)
        }
        return "-"
    }
    
}//end UIViewController

// MARK: - UIView
extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        
        self.layer.mask = mask
    }
    
    func  addTapGesture(action : @escaping ()->Void ){
        let tap = MyTapGestureRecognizer(target: self , action: #selector(self.handleTap(_:)))
        tap.action = action
        tap.numberOfTapsRequired = 1
        
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        
    }
    
    @objc func handleTap(_ sender: MyTapGestureRecognizer) {
        sender.action!()
    }
}

class MyTapGestureRecognizer: UITapGestureRecognizer {
    var action : (()->Void)? = nil
}

// MARK: - UIImageView
extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}


// MARK: - UIImage
extension UIImage {
    func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func convertImageToBase64String () -> String {
        return self.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
    }
}


// MARK: - UIButton
extension UIButton {
    func disableBtn() {
        isEnabled = false
        backgroundColor = UIColor.buttonDisable
        setTitleColor(.gray, for: .normal)
    }
    
    func enableBtn() {
        isEnabled = true
        backgroundColor = UIColor.buttonRed
        setTitleColor(.white, for: .normal)
    }
    
    func disableIconBtn() {
        isEnabled = false
        setTitleColor(.lightGray, for: .normal)
    }
    
    func enableIconBtn() {
        isEnabled = true
        setTitleColor(.white, for: .normal)
    }
}


// MARK: - UITextField
extension UITextField {
    func setUI () {
        self.borderStyle = .none
        self.layer.cornerRadius = 10.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}


// MARK: - String
extension String {
    func contains(_ find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    func containsIgnoringCase(_ find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    var html2AttributedString: NSAttributedString? {
        guard let data = data(using: .utf8)
        else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
                    }
        catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}


// MARK: - Date
extension Date {
    //    init(_ dateString:String) {
    //        let dateStringFormatter = DateFormatter()
    //        dateStringFormatter.locale = Locale(identifier: "en_US")
    //        dateStringFormatter.dateFormat = "yyyy-MM-dd"
    //        let date = dateStringFormatter.date(from: dateString)!
    //        self.init(timeInterval:0, since:date)
    //    }
}


// MARK: - DateFormatter
extension DateFormatter {
    //    static let iso8601Full: DateFormatter = {
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    //        formatter.calendar = Calendar(identifier: .iso8601)
    //        formatter.timeZone = TimeZone(secondsFromGMT: 0)
    //        formatter.locale = Locale(identifier: "en_US_POSIX")
    //        return formatter
    //    }()
    
    static let formatDateTH = "d MMMM yyyy"
    static let formatDateWithTimeTH = "d MMMM yyyy HH:mm:ss"
    
    static let serverFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US")//Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
    
    static let serverWihtTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US")//Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
    
    static let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th")
        formatter.calendar = Calendar(identifier: .buddhist)
        return formatter
    }()
}


// MARK: - UIAlertController & UIAlertAction
extension UIAlertController {
    func setColorAndFont(){
        
        let attributesTitle = [NSAttributedString.Key.foregroundColor: UIColor.textDarkGray, NSAttributedString.Key.font: UIFont.Prompt_Medium(ofSize: 20)]
        let attributesMessage = [NSAttributedString.Key.foregroundColor: UIColor.textDarkGray, NSAttributedString.Key.font: UIFont.Prompt_Regular(ofSize: 16)]
        let attributedTitleText = NSAttributedString(string: self.title ?? "", attributes: attributesTitle as [NSAttributedString.Key : Any])
        let attributedMessageText = NSAttributedString(string: self.message ?? "", attributes: attributesMessage as [NSAttributedString.Key : Any])
        
        self.setValue(attributedTitleText, forKey: "attributedTitle")
        self.setValue(attributedMessageText, forKey: "attributedMessage")
    }
}

extension UIAlertAction {
    var titleTextColor: UIColor? {
        get { return self.value(forKey: "titleTextColor") as? UIColor }
        set { self.setValue(newValue, forKey: "titleTextColor") }
    }
}

// MARK: - UICollectionViewCell
extension UICollectionViewCell {
    func setRoundAndShadow () {
        contentView.layer.cornerRadius = 15.0
        contentView.layer.borderWidth = 0.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0.0)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}
