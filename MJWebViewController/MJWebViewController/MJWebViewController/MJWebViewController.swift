//
//  MJWebViewController.swift
//  MJWebViewController
//
//  Created by Mejian on 2018/10/8.
//  Copyright © 2018年 Hainan Zhongrong Fintech Co.Ltd. All rights reserved.
//
//  仿微信WebView
//  带进度条、及前进后退按钮

import UIKit
import WebKit


private let kScreenWidth: CGFloat = UIScreen.main.bounds.width
private let kScreenHeight: CGFloat = UIScreen.main.bounds.height

private let kIsIphoneX: Bool = kScreenHeight >= 812.0 ? true : false
private let kStatusBarHeight: CGFloat! = kIsIphoneX ? 44.0 : 20.0
private let kNavBarHeight: CGFloat! = kIsIphoneX ? 88.0 : 64.0
private let kBottomHeight: CGFloat! = kIsIphoneX ? 83.0 : 49.0
private let kBottomMargin: CGFloat! = kIsIphoneX ? 34.0 : 0.0
private let MainColor = UIColor(white: 0.95, alpha: 1.0)

class MJWebViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {

    
    var webView = WKWebView()
    var urlString: String!
    var bottomView: UIView!
    var goBackBtn = UIButton.init(type: .custom)
    var goForwardBtn = UIButton.init(type: .custom)
    var titeLabel = UILabel()
    var progress = UIProgressView()
    
    var isFirstLoad = true
    var loadCount = 0
    var newContentOffsetY: CGFloat! = 0.0
    var oldContentOffsetY: CGFloat! = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        setupWebView()
        
        let request = URLRequest(url: URL(string: self.urlString)!)
        self.webView.load(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        //TODO:kvo监听，获得页面title和加载进度值
        webView.addObserver(self, forKeyPath: "title", options: NSKeyValueObservingOptions.new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)

    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    init(url: String!) {
        super.init(nibName: nil, bundle: nil)
        self.urlString = url
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWebView() {
        
        view.backgroundColor = MainColor
        // 导航View
        let navBarView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kNavBarHeight))
        navBarView.backgroundColor = MainColor
        view.addSubview(navBarView)
        
        // 关闭按钮
        let closeBtn = UIButton.init(type: .custom)
        closeBtn.frame = CGRect(x: 0, y: kStatusBarHeight, width: 50, height: 44)
        closeBtn.setImage(UIImage.init(named: "MJWebView_close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeBtnClicked), for: .touchUpInside)
        navBarView.addSubview(closeBtn)
        // titleView
        titeLabel.frame = CGRect(x: closeBtn.frame.maxX, y: kStatusBarHeight, width: kScreenWidth - closeBtn.frame.width * 2, height: closeBtn.frame.height)
        titeLabel.font = UIFont.init(name: "PingFangSC-Medium", size: 17)!
        titeLabel.textAlignment = .center
        navBarView.addSubview(titeLabel)
        
        let lineView = UIView(frame: CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: 0.3))
        lineView.backgroundColor = UIColor.init(white: 0.7, alpha: 1.0)
        navBarView.addSubview(lineView)
        // 进度条
        progress.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: 5)
        progress.progressTintColor = UIColor(red: 30/255.0, green: 190/255.0, blue: 30/255.0, alpha: 1.0)
        progress.trackTintColor = UIColor.clear
        progress.alpha = 0.0
        navBarView.addSubview(progress)
        
        // webView
        webView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - kBottomMargin)
        view.insertSubview(webView, belowSubview: navBarView)
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        
        // 底部View
        bottomView = UIView(frame: CGRect(x: 0, y: kScreenHeight - kBottomHeight, width: kScreenWidth, height: 49))
        bottomView.backgroundColor = MainColor
        bottomView.isHidden = true
        view.addSubview(bottomView)
        
        let bottomLineView = UIView(frame: CGRect(x: 0, y: -0.5, width: kScreenWidth, height: 0.5))
        bottomLineView.backgroundColor = UIColor.init(white: 0.8, alpha: 1.0)
        bottomView.addSubview(bottomLineView)
        // 后退按钮
        goBackBtn.frame = CGRect(x: kScreenWidth/2.0 - 80, y: 0, width: 60, height: 49)
        goBackBtn.setImage(UIImage.init(named: "MJWebView_goBack"), for: .normal)
        goBackBtn.addTarget(self, action: #selector(goBackBtnClicked), for: .touchUpInside)
        bottomView.addSubview(goBackBtn)
        // 前进按钮
        goForwardBtn.frame = CGRect(x: kScreenWidth/2.0 + 20, y: 0, width: 60, height: 49)
        goForwardBtn.setImage(UIImage.init(named: "MJWebView_goForward"), for: .normal)
        goForwardBtn.addTarget(self, action: #selector(goForwardBtnClicked), for: .touchUpInside)
        bottomView.addSubview(goForwardBtn)

    }
    
    @objc func closeBtnClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func goBackBtnClicked() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc func goForwardBtnClicked() {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    // KVO的监听代理
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (object as! WKWebView) == webView {
            if keyPath == "title" {
                // 标题
                titeLabel.text = webView.title
            } else if keyPath == "estimatedProgress" {
                // 加载进度值
                print("网页加载进度:\(webView.estimatedProgress)")
                progress.alpha = 1.0
                progress.setProgress(Float(webView.estimatedProgress), animated: true)
                if webView.estimatedProgress >= 1.0 {
                    UIView.animate(withDuration: 0.2, delay: 0.2, options: UIView.AnimationOptions.curveEaseOut, animations: {
                        self.progress.alpha = 0.0
                    }, completion: { (finished) in
                        self.progress.setProgress(0.0, animated: false)
                    })
                }
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    // 滚动监听底部隐藏
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        newContentOffsetY = scrollView.contentOffset.y
        
        if loadCount <= 1 { return }
        if (newContentOffsetY > 20) && (newContentOffsetY > oldContentOffsetY) {
            bottomView.isHidden = true
            if newContentOffsetY < scrollView.contentSize.height - scrollView.frame.height {
                
                oldContentOffsetY = newContentOffsetY
            }
        } else if (newContentOffsetY < oldContentOffsetY) {
            if newContentOffsetY < scrollView.contentSize.height - scrollView.frame.height - 49 {
                bottomView.isHidden = false
                oldContentOffsetY = newContentOffsetY
            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        bottomView.isHidden = loadCount < 1
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadCount = loadCount + 1
        goBackBtn.isEnabled = webView.canGoBack
        goForwardBtn.isEnabled = webView.canGoForward
        isFirstLoad = false
    }
}
