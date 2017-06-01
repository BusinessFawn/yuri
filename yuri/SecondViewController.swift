//
//  SecondViewController.swift
//  yuri
//
//  Created by John Konderla on 5/20/17.
//  Copyright © 2017 John Konderla. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addBottomSheetView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addBottomSheetView(scrollable: Bool? = true) {
        let bottomSheetVC = scrollable! ? BottomSheetViewController() : ScrollableBottomSheetViewController()
        
        
        self.addChildViewController(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParentViewController: self)
        
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
    }
    
}

