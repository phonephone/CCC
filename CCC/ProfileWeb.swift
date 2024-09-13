//
//  ProfileWeb.swift
//  CCC
//
//  Created by Truk Karawawattana on 3/7/2567 BE.
//

import UIKit
import ProgressHUD
import WebKit
import SwiftAlertView

class ProfileWeb: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var myWebView: WKWebView!
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var bottomView: UIView!
    //@IBOutlet weak var myWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PROFILE WEB")
        
        self.navigationController?.setStatusBar(backgroundColor: .themeColor)
        
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
        
        let url = URL(string: SceneDelegate.GlobalVariables.profileURL)!
        myWebView.load(URLRequest(url: url))
        
        SceneDelegate.GlobalVariables.reloadHome = true
        SceneDelegate.GlobalVariables.reloadMyCalory = true
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
    
    @IBAction func leftMenuShow(_ sender: UIButton) {
        self.sideMenuController!.revealMenu()
    }
}

