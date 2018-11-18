//
//  ViewController.swift
//  ButtonScrollViewSample
//
//  Created by Park on 2018/11/15.
//  Copyright © 2018年 park. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var iconButtonAreaView: UIView!

    var buttonScrollVC: ButtonScrollViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initButtonScrollVC()
    }

    private func initButtonScrollVC() {
        let storyboard = UIStoryboard(name: "ButtonScroll", bundle: Bundle(for: ViewController.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "ButtonScrollViewController") as! ButtonScrollViewController
        buttonScrollVC = viewController
        iconButtonAreaView.frame = self.view.frame
        iconButtonAreaView.addSubview(buttonScrollVC.view)
        
        iconButtonAreaView.layer.backgroundColor = UIColor.hexStr("000000", alpha: 0.1).cgColor
        iconButtonAreaView.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        iconButtonAreaView.layer.shadowRadius = 1.0
        iconButtonAreaView.layer.shadowOpacity = 0.1
    }


}

