//
//  ViewController.swift
//  MJWebViewController
//
//  Created by Apple on 2018/10/9.
//  Copyright © 2018年 Hainan Zhongrong Fintech Co.Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        
        
    }
    
    @IBAction func pushWebViewController(_ sender: Any) {
        
        let webView = MJWebViewController.init(url: "https://www.hao123.com")
        self.navigationController?.pushViewController(webView, animated: true)
    }

}

