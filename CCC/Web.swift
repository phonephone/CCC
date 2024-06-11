//
//  Web.swift
//  CCC
//
//  Created by Truk Karawawattana on 14/1/2565 BE.
//

import UIKit
import ProgressHUD
import WebKit
import SwiftAlertView

class Web: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var titleString:String?
    var webUrlString:String?
    
    var myWebView: WKWebView!
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var bottomView: UIView!
    //@IBOutlet weak var myWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WEB = \(webUrlString)")
        
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
        headerTitle.text = titleString
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        myWebView = WKWebView(frame: bottomView.frame, configuration: configuration)
        myWebView.uiDelegate = self
        myWebView.navigationDelegate = self
        
        myWebView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(myWebView)
        
        NSLayoutConstraint.activate([
            myWebView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            myWebView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            myWebView.topAnchor.constraint(equalTo: bottomView.topAnchor),
            myWebView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor)
        ])
        
        let url = URL(string: webUrlString!)!
        //let url = URL(string: "https://www.google.com")!
        
        //let url = URL(string: "https://ccc.mots.go.th/ccc_reward/redeem/377388/de0741f771b475bf844d3768dfb544fe")!
        //let url = URL(string: "https://ccc.mots.go.th/ccc_reward/thaiID/377388")!
        
        myWebView.load(URLRequest(url: url))
        //myWebView.loadHTMLString("", baseURL: nil)
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingHUD()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        
//        guard let urlAsString = navigationAction.request.url?.absoluteString.lowercased() else {
//            return
//        }
        
        if let url = navigationAction.request.url, let scheme = url.scheme?.lowercased() {
            print("url = \(url)")
            
            if scheme != "https" && scheme != "http" {//check deeplink?
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.open(url)
                }
            }
            else{
                if url.absoluteString.contains("Thaiid/sqrcode") {
                    goBackToFirst()
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    func goBackToFirst() {
        let historySize = myWebView.backForwardList.backList.count
        print(historySize)
        let firstItem = myWebView.backForwardList.item(at: -historySize)
        
        myWebView.go(to: firstItem!)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame?.isMainFrame != true {
            webView.load(navigationAction.request)
        }
        
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        SwiftAlertView.show(title: message,
                            message: nil,
                            buttonTitles: "ตกลง") { alert in
            //alert.backgroundColor = .yellow
            alert.titleLabel.font = .Alert_Title
            alert.messageLabel.font = .Alert_Message
            alert.cancelButtonIndex = 0
            alert.button(at: 0)?.titleLabel?.font = .Alert_Button
            alert.button(at: 0)?.setTitleColor(.themeColor, for: .normal)
            //            alert.buttonTitleColor = .themeColor
        }
                            .onButtonClicked { _, buttonIndex in
                                print("Button Clicked At Index \(buttonIndex)")
                                switch buttonIndex{
                                default:
                                    completionHandler()
                                    break
                                }
                            }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        SwiftAlertView.show(title: message,
                            message: nil,
                            buttonTitles: "ยกเลิก", "ตกลง") { alert in
            //alert.backgroundColor = .yellow
            alert.titleLabel.font = .Alert_Title
            alert.messageLabel.font = .Alert_Message
            alert.cancelButtonIndex = 0
            alert.button(at: 0)?.titleLabel?.font = .Alert_Button
            alert.button(at: 0)?.setTitleColor(.buttonRed, for: .normal)
            
            alert.button(at: 1)?.titleLabel?.font = .Alert_Button
            alert.button(at: 1)?.setTitleColor(.themeColor, for: .normal)
            //            alert.buttonTitleColor = .themeColor
        }
                            .onButtonClicked { _, buttonIndex in
                                print("Button Clicked At Index \(buttonIndex)")
                                switch buttonIndex{
                                case 1:
                                    completionHandler(true)
                                default:
                                    completionHandler(false)
                                    break
                                }
                            }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        SwiftAlertView.show(title: prompt, buttonTitles: "ยกเลิก", "ตกลง") { alertView in
            alertView.addTextField { textField in
                textField.placeholder = defaultText
            }
            //alertView.isEnabledValidationLabel = true
            alertView.isDismissOnActionButtonClicked = false
        }
        .onActionButtonClicked { alertView, buttonIndex in
            switch buttonIndex{
            case 1:
                let inputText = alertView.textField(at: 0)?.text ?? ""
                if inputText.isEmpty {
                    completionHandler(defaultText)
                    //alertView.validationLabel.text = "Field is empty"
                } else {
                    completionHandler(inputText)
                    alertView.dismiss()
                }
            default:
                completionHandler(nil)
                alertView.dismiss()
                break
            }
        }
//        .onTextChanged { _, text, textFieldIndex in
//            if textFieldIndex == 0 {
//                print("text changed: ", text ?? "")
//            }
//        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
