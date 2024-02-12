//
//  Share.swift
//  CCC
//
//  Created by Truk Karawawattana on 7/4/2565 BE.
//

import UIKit
import ProgressHUD
import AVFoundation
import Photos
import Alamofire
import SwiftyJSON

class Share: UIViewController, UIGestureRecognizerDelegate {
    
    var typeJSON : JSON?
    var stickerJSON : JSON?
    
    var typeID : String? = "0"
    
    var selectedStickerID : String?
    
    var totalDistance: Double!
    var totalDuration: Double!
    var totalStep: Int!
    var totalCalories: Double!
    
    var startDate: Date!
    var endDate: Date!
    
    var imgSticker: UIImageView!
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var sharePic: UIImageView!
    @IBOutlet weak var stickerPic: UIImageView!
    @IBOutlet weak var templateView: UIView!
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var typeBtn: UIButton!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    var typePicker: UIPickerView! = UIPickerView()
    
    var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute]//, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
    
    private var _selectedStickerView:StickerView?
    var selectedStickerView:StickerView? {
        get {
            return _selectedStickerView
        }
        set {
            
            // if other sticker choosed then resign the handler
            if _selectedStickerView != newValue {
                if let selectedStickerView = _selectedStickerView {
                    selectedStickerView.showEditingHandlers = false
                }
                _selectedStickerView = newValue
            }
            
            // assign handler to new sticker added
            if let selectedStickerView = _selectedStickerView {
                selectedStickerView.showEditingHandlers = true
                selectedStickerView.superview?.bringSubviewToFront(selectedStickerView)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SHARE")
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        sharePic.addGestureRecognizer(tapGestureRecognizer)
        sharePic.isUserInteractionEnabled = true
        
        userPic.sd_setImage(with: URL(string:SceneDelegate.GlobalVariables.userPicURL), placeholderImage: UIImage(named: "icon_profile"))
        
        dateLabel.text = appStringFromDate(date: startDate, format: "d MMMM yyyy")
        
        if totalDistance == 0 {
            distanceLabel.text = "-"
        }
        else{
            distanceLabel.text = String(format: "%.2f", totalDistance)
        }
        
        timeLabel.text = durationFormatter.string(from: TimeInterval(totalDuration))!
        //stepLabel.text = String(totalStep)
        calorieLabel.text = String(format: "%.0f", totalCalories)
        
        pickerSetup(picker: typePicker)
        typeField.inputView = typePicker
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        loadType()
        
        chooseImageSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //changeSticker(stickerUrl: "", templateNumber: 1, textColor: .white)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //chooseImageSource()
        //self.selectedStickerView?.showEditingHandlers = false
    }
    
    func loadType() {
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID]
        loadRequest_V2(method:.get, apiName:"Sticker_template/category", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS STICKER TYPE\(json)")
                
                self.typeJSON = json["data"]
                self.typePicker.reloadAllComponents()
                
                if self.typeJSON?.count != 0 {
                    self.typeField.text = self.typeJSON![0]["category_name"].stringValue
                    self.typeID = self.typeJSON![0]["category_id"].stringValue
                }
                self.loadList()
            }
        }
    }
    
    func loadList() {
        stickerJSON = []
        myCollectionView.reloadData()
        
        let parameters:Parameters = ["user_id":SceneDelegate.GlobalVariables.userID,
                                     "category_id":typeID!
        ]
        loadRequest_V2(method:.get, apiName:"Sticker_template", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS STICKER\(json)")
                
                self.stickerJSON = json["data"]
                
                self.myCollectionView.reloadData()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == typeField && typeField.text == "" {
            selectPicker(typePicker, didSelectRow: 0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func pickerSetup(picker:UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
    }
    
    @IBAction func typeClick(_ sender: UIButton) {
        typeField.becomeFirstResponder()
    }
    
    @IBAction func cameraClick(_ sender: UIButton) {
        chooseImageSource()
    }
    
    @IBAction func shareClick(_ sender: UIButton) {
        self.selectedStickerView?.showEditingHandlers = false
        screenShot()
    }
    
    @IBAction func templateClick(_ sender: UIButton) {
        changeSticker(stickerUrl: "", templateNumber: 1, textColor: .white)
    }
    
    @IBAction func stickerClick(_ sender: UIButton) {
        addStickers(image: UIImage(named: "demo_manual3")!)
    }
    
    func changeSticker(stickerUrl:String, templateNumber:Int, textColor:UIColor) {
        stickerPic.sd_setImage(with: URL(string:stickerUrl), placeholderImage: nil)
        
        let viewTemplate = ShareTemplate(frame: templateView.frame)
        viewTemplate.commonInit(withTemplate:templateNumber, withTextColor:textColor)
        
        viewTemplate.userPic.sd_setImage(with: URL(string:SceneDelegate.GlobalVariables.userPicURL), placeholderImage: UIImage(named: "icon_profile"))
        
        viewTemplate.dateLabel.text = appStringFromDate(date: startDate, format: "d MMMM yyyy")
        
        if totalDistance == 0 {
            viewTemplate.distanceLabel.text = "-"
        }
        else{
            viewTemplate.distanceLabel.text = String(format: "%.2f", totalDistance)
        }
        
        viewTemplate.timeLabel.text = durationFormatter.string(from: TimeInterval(totalDuration))!
        viewTemplate.calorieLabel.text = String(format: "%.0f", totalCalories)
        
        for view in templateView.subviews {
            view.removeFromSuperview()
        }
        templateView.addSubview(viewTemplate)
    }
    
    func addStickers(image: UIImage) {
        //        // UIView as a container
        //        let testView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 150, height: 100))
        //        testView.backgroundColor = UIColor.red
        //
        //        let stickerView = StickerView.init(contentView: testView)
        //        stickerView.center = self.view.center
        //        stickerView.delegate = self
        //        stickerView.outlineBorderColor = UIColor.blue
        //        stickerView.setImage(UIImage.init(named: "Close")!, forHandler: StickerViewHandler.close)
        //        stickerView.setImage(UIImage.init(named: "Rotate")!, forHandler: StickerViewHandler.rotate)
        //        stickerView.setImage(UIImage.init(named: "Flip")!, forHandler: StickerViewHandler.flip)
        //        stickerView.setHandlerSize(40)
        //        self.view.addSubview(stickerView)
        //
        //        // UILabel as a container
        //        let testLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 50))
        //        testLabel.text = "Test Label"
        //        testLabel.textAlignment = .center
        //
        //        let stickerView2 = StickerView.init(contentView: testLabel)
        //        stickerView2.center = CGPoint.init(x: 100, y: 100)
        //        stickerView2.delegate = self
        //        stickerView2.setImage(UIImage.init(named: "Close")!, forHandler: StickerViewHandler.close)
        //        stickerView2.setImage(UIImage.init(named: "Rotate")!, forHandler: StickerViewHandler.rotate)
        //        stickerView2.showEditingHandlers = false
        //        self.view.addSubview(stickerView2)
        
        // UIImageView as a container
        let testImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        testImage.image = image
        testImage.contentMode = UIView.ContentMode.scaleAspectFit
        
        let stickerView3 = StickerView.init(contentView: testImage)
        stickerView3.center = CGPoint.init(x: 150, y: 150)
        stickerView3.delegate = self
        stickerView3.setImage(UIImage.init(named: "history_cal")!, forHandler: StickerViewHandler.close)
        stickerView3.setImage(UIImage.init(named: "history_distance")!, forHandler: StickerViewHandler.rotate)
        stickerView3.setImage(UIImage.init(named: "history_duration")!, forHandler: StickerViewHandler.flip)
        stickerView3.showEditingHandlers = false
        sharePic.addSubview(stickerView3)
        
        // first off assign handler to stickerView
        self.selectedStickerView = stickerView3
        
//        imgSticker  = UIImageView(frame: CGRect.init(x: 0.0, y: 0.0, width: 80, height: 80))
//        imgSticker.center = shareView.center
//        imgSticker.image = image
//        imgSticker.contentMode = UIView.ContentMode.scaleAspectFill
//        imgSticker.isUserInteractionEnabled = true
//
//        shareView.addSubview(imgSticker)
//        //imgImage.addSubview(imgSticker)
//
//        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGesture(_:)))
//        panGesture.delegate = self
//
//        let pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinchGesture(_:)))
//        pinchGesture.delegate = self
//
//        let rotateGesture = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotateGesture(_:)))
//        rotateGesture.delegate = self
//
//        imgSticker.addGestureRecognizer(panGesture)
//        imgSticker.addGestureRecognizer(pinchGesture)
//        imgSticker.addGestureRecognizer(rotateGesture)
    }
//
//    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
//        let recognizerCenter = recognizer.location(in: shareView)
//        imgSticker.center = recognizerCenter
//    }
//
//    @objc func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
//        imgSticker.transform = imgSticker.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
//        recognizer.scale = 1.0
//    }
//
//    @objc func handleRotateGesture(_ recognizer: UIRotationGestureRecognizer) {
//        imgSticker.transform = imgSticker.transform.rotated(by: recognizer.rotation)
//        recognizer.rotation = 0.0
//    }
    
    func screenShot() {
        // Setting description
        //let firstActivityItem = "Test Share Button"
        
        // Setting url
        //let secondActivityItem : NSURL = NSURL(string: "https://fw.f12key.xyz/")!
        
        // If you want to use an image
        
        let image : UIImage = shareView.asShareImage()
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [image], applicationActivities: nil)
        //let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        //activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
        
        // This line remove the arrow of the popover to show in iPad
        //activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        //activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            //UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            //UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            //UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
        //self.navigationController!.popToRootViewController(animated: true)
    }
}

// MARK: - Picker Datasource
extension Share: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == typePicker && typeJSON!.count > 0{
            return typeJSON!.count
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = .Prompt_Regular(ofSize: 22)
            pickerLabel?.textAlignment = .center
        }
        
        if pickerView == typePicker && typeJSON!.count > 0{
            pickerLabel?.text = typeJSON![row]["category_name"].stringValue
        }
        else{
            pickerLabel?.text = ""
        }
        
        pickerLabel?.textColor = .textDarkGray
        
        return pickerLabel!
    }
}

// MARK: - Picker Delegate
extension Share: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == typePicker {
            typeField.text = typeJSON![row]["category_name"].stringValue
            typeID = typeJSON![row]["category_id"].stringValue
            
            loadList()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension Share: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (stickerJSON != nil) {
            return  stickerJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = stickerJSON![indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"StickerCell", for: indexPath) as! CategoryCell
        cell.cellImage.sd_setImage(with: URL(string:cellArray["sticker_url"].stringValue), placeholderImage: nil)
        
        if selectedStickerID == cellArray["sticker_id"].stringValue {
            cell.layer.borderColor = UIColor.themeColor.cgColor
            cell.layer.borderWidth = 3
        }
        else {
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 0
        }
        //cell.cellTitle.text = cellArray["act_name_th"].stringValue
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension Share: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = (myCollectionView.frame.size.width/3)-40
        let cellHeight = cellWidth
        return CGSize(width: cellWidth , height: cellHeight)
        //return CGSize(width: 150 , height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}

// MARK: - UICollectionViewDelegate

extension Share: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let cellArray = stickerJSON![indexPath.item]
        //stickerPic.sd_setImage(with: URL(string:cellArray["sticker_url"].stringValue), placeholderImage: nil)
        
        selectedStickerID = cellArray["sticker_id"].stringValue
        myCollectionView.reloadData()
        
        changeSticker(stickerUrl: cellArray["sticker_url"].stringValue, templateNumber: cellArray["template_id"].intValue, textColor: colorFromRGB(rgbString:cellArray["color_code_rgb"].stringValue))
    }
}

// MARK: - UIImagePickerControllerDelegate

extension Share: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImageSource()
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.checkPermission(camera: true)
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.checkPermission(camera: false)
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        alert.actions.last?.titleTextColor = .buttonRed
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkPermission(camera:Bool)
    {
        if camera == true {
            //Camera Permission
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { success in
                if success {
                    //Camera access granted
                    DispatchQueue.main.async {
                        self.openCamera()
                    }
                } else {
                    //No Camera access
                    DispatchQueue.main.async {
                        self.askPermission(camera: true)
                    }
                }
            }
        }
        else{
            //Photos Permission
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
                self.openGallery()
                
            case .denied, .restricted :
                askPermission(camera: false)
                
            case .notDetermined:
                // ask for permissions
                PHPhotoLibrary.requestAuthorization { status in
                    switch status {
                    case .authorized:
                        self.openGallery()
                    case .denied, .restricted:
                        self.askPermission(camera: false)
                    case .notDetermined: // won't happen but still
                        break
                    case .limited:
                        break
                    @unknown default:
                        break
                    }
                }
                
            case .limited:
                break
            @unknown default:
                break
            }
        }
    }
    
    func askPermission(camera:Bool)
    {
        if camera == true {//Camera
            let alert = UIAlertController(title: "Your Camera Access Denied", message: "Please allow camera access to upload profile photo", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                
            }))
            alert.actions.last?.titleTextColor = .buttonRed
            
            alert.addAction(UIAlertAction(title: "Go to Setting", style: .default, handler: { action in
                
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            alert.actions.last?.titleTextColor = .themeColor
            
            self.present(alert, animated: true)
        }
        else{//Photo Library
            let alert = UIAlertController(title: "Your Photo Library Access Denied", message: "Please allow photo library access to upload profile photo", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                
            }))
            alert.actions.last?.titleTextColor = .buttonRed
            
            alert.addAction(UIAlertAction(title: "Go to Setting", style: .default, handler: { action in
                
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            alert.actions.last?.titleTextColor = .themeColor
            
            self.present(alert, animated: true)
        }
    }
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            DispatchQueue.main.async {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.editedImage] as? UIImage {
            // imageViewPic.contentMode = .scaleToFill
            sharePic.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asShareImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

// MARK: StickerViewDelegate
extension Share: StickerViewDelegate {
    func stickerViewDidBeginMoving(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
    }
    
    func stickerViewDidChangeMoving(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidEndMoving(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidBeginRotating(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidChangeRotating(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidEndRotating(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidClose(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidTap(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
    }
}
