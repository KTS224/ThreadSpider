//
//  ModalViewController.swift
//  PopularSearcherApp
//
//  Created by 김태성 on 12/3/23.
//

import UIKit
import WebKit

class ModalViewController: UIViewController, WKNavigationDelegate{
    var selectedWord: String = "1"
    @IBOutlet var myWebView: WKWebView!
    @IBOutlet var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var lblItem: UILabel!
    
    func loadWebPage(_ url: String) {
        let myUrl = URL(string: url)
        let myRequest = URLRequest(url: myUrl!)
        
        myWebView.load(myRequest)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(selectedWord)
        lblItem.text = selectedWord
        
        myWebView.navigationDelegate = self
        self.loadWebPage("https://search.daum.net/nate?&w=news&q=\(selectedWord)")
    }
    
    func selectedWord(_ item: String) {
        selectedWord = item
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        myActivityIndicator.startAnimating()
        myActivityIndicator.isHidden = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        myActivityIndicator.stopAnimating()
        myActivityIndicator.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        myActivityIndicator.stopAnimating()
        myActivityIndicator.isHidden = true
    }
    
    @IBAction func btnStop(_ sender: UIBarButtonItem) {
        myWebView.stopLoading()
    }
    
    @IBAction func btnReload(_ sender: UIBarButtonItem) {
        myWebView.reload()
    }
    
    @IBAction func btnGoBack(_ sender: Any) {
        myWebView.goBack()
    }
    
    @IBAction func btnGoForward(_ sender: Any) {
        myWebView.goForward()
    }
}
