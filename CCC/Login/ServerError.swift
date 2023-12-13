//
//  ServerError.swift
//  CCC
//
//  Created by Truk Karawawattana on 23/9/2565 BE.
//

import UIKit
import ProgressHUD
import WebKit

class ServerError: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var myWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SERVER ERROR")
        self.navigationController?.setStatusBar(backgroundColor: .themeBgColor)
        
        let url = URL(string: "https://ccc.mots.go.th/home/content/12")!
        myWebView.load(URLRequest(url: url))
        //myWebView.loadHTMLString("", baseURL: nil)
        myWebView.navigationDelegate = self
        myWebView.allowsBackForwardNavigationGestures = true
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        ProgressHUD.show("Loading", interaction: true)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        guard let urlAsString = navigationAction.request.url?.absoluteString.lowercased() else {
            return
        }
        
        if urlAsString.range(of: "the url that the button redirects the webpage to") != nil {
            // do something
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func retryClick(_ sender: UIButton) {
        if SceneDelegate.GlobalVariables.userID == "" {
            switchToLogin()
        }
        else {
            switchToHome()
        }
    }
}

