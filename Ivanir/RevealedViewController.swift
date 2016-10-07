//
//  RevealedViewController.swift
//  Ivanir
//
//  Created by Jagni Dasa Horta Bezerra on 9/6/16.
//  Copyright © 2016 Jagni. All rights reserved.
//

import Foundation
import UIKit
import ColorMatchTabs

class RevealedViewController : ColorMatchTabsViewController, ColorMatchTabsViewControllerDataSource {
    
    let viewControllerIds = ["PhotoController", "AudioController", "SimpleRiddleController"]
    let viewControllerNames = ["Foto", "Audio", "Charada"]
    var controllers = [UIViewController]()
    let tintColors = [UIColor ( red: 1.0, green: 0.3333, blue: 0.3333, alpha: 1.0 ), UIColor ( red: 1.0, green: 0.3333, blue: 0.3333, alpha: 1.0 ), UIColor ( red: 1.0, green: 0.3333, blue: 0.3333, alpha: 1.0 )  ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.reloadData()
        self.titleLabel.text = "Feedback do Dia :D"
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.font = UIFont(name: "AmaticSC-Bold", size: 25)!
        
        self.navigationController?.navigationBar.tintColor = UIColor ( red: 0.1433, green: 0.0937, blue: 0.0978, alpha: 1.0 )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for controller in controllers{
            controller.viewDidAppear(animated)
        }
    }
    
    func numberOfItems(inController controller: ColorMatchTabsViewController) -> Int{
        return viewControllerIds.count
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, viewControllerAt index: Int) -> UIViewController{
        let controller = self.storyboard?.instantiateViewController(withIdentifier: viewControllerIds[index])
        controllers.append(controller!)
        return controller!
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, titleAt index: Int) -> String{
        
        return viewControllerNames[index]
        
    }
    func tabsViewController(_ controller: ColorMatchTabsViewController, iconAt index: Int) -> UIImage{
        
        return UIImage(named: viewControllerNames[index])!
        
    }
    
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, hightlightedIconAt index: Int) -> UIImage{
        
        return UIImage(named: viewControllerNames[index] + "High")!
        
    }
    
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, tintColorAt index: Int) -> UIColor{
        
        return tintColors[index]
        
    }
    
}
