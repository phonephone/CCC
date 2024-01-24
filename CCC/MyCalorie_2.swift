//
//  MyCalorie_2.swift
//  CCC
//
//  Created by Truk Karawawattana on 14/12/2566 BE.
//

import HealthKit
import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Charts
import SkeletonView

class MyCalorie_2: UIViewController, ChartViewDelegate {
    
    var myJSON : JSON?
    var yValues: [ChartDataEntry] = []
    
    var firstTime = true
    
    var dayOfWeek: [String]!
    var caloriesBurn = [Double]()
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var profileStackView: UIStackView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myStackView: UIStackView!
    @IBOutlet weak var totalCaloriesLabel: UILabel!
    @IBOutlet weak var myChartView: LineChartView!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var bmiLabelTop: UILabel!
    @IBOutlet weak var bmiLabelBottom: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var shareView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dateLabel.text = appStringFromDate(date: Date(), format: "d MMMM yyyy")
        
        loadMyCalories()
        
        firstTime = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MYCALORIE_2")
        
        self.view.showAnimatedGradientSkeleton()
        
        myScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        shareBtn.imageView?.contentMode = .scaleAspectFit
        shareBtn.contentHorizontalAlignment = .fill
        shareBtn.contentVerticalAlignment = .fill
        shareBtn.imageEdgeInsets = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 0);
        shareBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 25);
        //shareBtn.imageEdgeInsets = UIEdgeInsets(top: 12, left: 60, bottom: 12, right: 0);
        //shareBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50);
        
        //myChartView.backgroundColor = .buttonRed
        //myChartView.delegate = self
        //myChartView.noDataText = "You need to provide data for the chart."
        myChartView.noDataTextColor = .white
        myChartView.rightAxis.enabled = false
        myChartView.legend.enabled = false
        //myChartView.animate(xAxisDuration: 1)
        myChartView.isUserInteractionEnabled = false
        
        let yAxis = myChartView.leftAxis
        yAxis.labelFont = .Roboto_Regular(ofSize: 8)
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        yAxis.gridColor = .white
        //yAxis.drawZeroLineEnabled = true
        //yAxis.zeroLineColor = .white
        yAxis.axisMinimum = 0
        
        let xAxis = myChartView.xAxis
        xAxis.enabled = true
        xAxis.drawLabelsEnabled = false
//        xAxis.labelPosition = .bottom
//        xAxis.labelFont = .Roboto_Regular(ofSize: 12)
//        xAxis.labelTextColor = .white
        xAxis.axisLineColor = .white
        xAxis.gridColor = .white
        
        
        //String Axis
//        axisFormatDelegate = self
//        dayOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
//        caloriesBurn = [123.0, 751.0, 625.0, 234.0, 999.0, 888.0, 789.0]
//        setChart(dataEntryX: dayOfWeek, dataEntryY: caloriesBurn)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        //totalCaloriesLabel.text = formatter.string(from: 5700200)
    }
    
    func loadMyCalories() {
        let parameters:Parameters = ["id":SceneDelegate.GlobalVariables.userID]
        loadRequest(method:.post, apiName:"my_kcal", authorization:true, showLoadingHUD:firstTime, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS MY CAL\(json)")
                
                self.myJSON = json["data"][0]
                
                self.updateDisplay()
            }
        }
    }
    
    func updateDisplay() {
        profilePic.sd_setImage(with: URL(string:myJSON!["user_img"].stringValue), placeholderImage: UIImage(named: "icon_profile"))
        nameLabel.text = myJSON!["first_name"].stringValue
        totalCaloriesLabel.text = myJSON!["user_sum_cal"].stringValue
        weightLabel.text = myJSON!["weight"].stringValue
        heightLabel.text = myJSON!["height"].stringValue
        bmiLabelTop.text = "ดัชนีมวลกาย (BMI) =  \(myJSON!["avg_bmi"].stringValue)"
        bmiLabelBottom.text = "รูปร่าง = \(myJSON!["avg_shape"].stringValue)"
        
        let graphArray = myJSON!["data_graph"]
        yValues = [
            ChartDataEntry(x: 0.0, y: graphArray[0]["value"].doubleValue),
            ChartDataEntry(x: 1.0, y: graphArray[1]["value"].doubleValue),
            ChartDataEntry(x: 2.0, y: graphArray[2]["value"].doubleValue),
            ChartDataEntry(x: 3.0, y: graphArray[3]["value"].doubleValue),
            ChartDataEntry(x: 4.0, y: graphArray[4]["value"].doubleValue),
            ChartDataEntry(x: 5.0, y: graphArray[5]["value"].doubleValue),
            ChartDataEntry(x: 6.0, y: graphArray[6]["value"].doubleValue),
        ]
        setData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.00) {
            self.view.hideSkeleton()
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func setData() {
        let line1 = LineChartDataSet(entries: yValues)
        //line1.mode = .cubicBezier
        line1.lineWidth = 2
        line1.colors = [NSUIColor.white]
        line1.drawValuesEnabled = false
        //line1.valueTextColor = .white
        //line1.valueFont = .Roboto_Regular(ofSize: 12)
        line1.drawCirclesEnabled = false
        line1.drawCircleHoleEnabled = false
        
        line1.drawHorizontalHighlightIndicatorEnabled = false
        line1.drawVerticalHighlightIndicatorEnabled = false
        
        let data = LineChartData(dataSet: line1)
        myChartView.data = data
    }
    
//    let yValues: [ChartDataEntry] = [ChartDataEntry(x: 0.0, y: 123.0),
//                                     ChartDataEntry(x: 1.0, y: 751.0),
//                                     ChartDataEntry(x: 2.0, y: 625.0),
//                                     ChartDataEntry(x: 3.0, y: 234.0),
//                                     ChartDataEntry(x: 4.0, y: 999.0),
//                                     ChartDataEntry(x: 5.0, y: 500.0),
//                                     ChartDataEntry(x: 6.0, y: 789.0),
//    ]
    
    //String Axis
//    func setChart(dataEntryX forX:[String],dataEntryY forY: [Double]) {
//        var dataEntries:[ChartDataEntry] = []
//        for i in 0..<forX.count{
//            // print(forX[i])
//            // let dataEntry = BarChartDataEntry(x: (forX[i] as NSString).doubleValue, y: Double(unitsSold[i]))
//            let dataEntry = ChartDataEntry(x: Double(i), y: Double(forY[i]) , data: dayOfWeek as AnyObject?)
//            print(dataEntry)
//            dataEntries.append(dataEntry)
//        }
//        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "Units Sold")
//        let chartData = LineChartData(dataSet: chartDataSet)
//        myChartView.data = chartData
//
//        let xAxisValue = myChartView.xAxis
//        xAxisValue.valueFormatter = axisFormatDelegate
//    }
    
    @IBAction func leftMenuShow(_ sender: UIButton) {
        self.sideMenuController!.revealMenu()
    }
    
    @IBAction func shareClick(_ sender: UIButton) {
        shareView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { // Change `2.0` to the desired number of seconds.
           // Code you want to be delayed
            self.screenShot()
        }
    }
    
    func screenShot() {
        // Setting description
        //let firstActivityItem = "Test Share Button"
        
        // Setting url
        //let secondActivityItem : NSURL = NSURL(string: "https://fw.f12key.xyz/")!
        
        // If you want to use an image
        
        let image : UIImage = myStackView.asImage()
        shareView.isHidden = false
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
    
    @IBAction func rankingClick(_ sender: UIButton) {
        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Ranking") as! Ranking
        self.navigationController!.pushViewController(vc, animated: true)
    }
}

extension UIStackView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
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

