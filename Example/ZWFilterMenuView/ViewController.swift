//
//  ViewController.swift
//  ZWFilterMenuView
//
//  Created by zhangwei2318 on 11/29/2021.
//  Copyright (c) 2021 zhangwei2318. All rights reserved.
//

import UIKit
import ZWFilterMenuView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .white
        
        view.addSubview(screeningV)
        screeningV.titleArray = ["测试", "开发", "上线"]
//        screeningV.openFrame = CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        screeningV.filterStrArray = [["123", "12", "23", "13", "1"], nil, ["1234", "423"]]
        
    }
    
    
    private lazy var screeningV: ZWFilterMenuView = {
        let view = ZWFilterMenuView.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 44))
        view.maxCellLine = 8
//        view.titleNormalColor = .red
        view.menuBarBackgroundColor = .yellow
        view.titleSelectColor = UIColor.red
//        view.isBackGroundTapDismiss = false
        view.barAction = { (index, show) in
            
        }
        
        view.cellAction = {[weak self] (barIndex, cellIndex) in

        }
        return view
    }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

