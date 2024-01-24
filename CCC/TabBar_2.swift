//
//  TabBar_2.swift
//  CCC
//
//  Created by Truk Karawawattana on 24/10/2566 BE.
//

import UIKit

class TabBar_2: UITabBarController {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.tintColor = .themeColor
        self.tabBar.unselectedItemTintColor = .textGray1
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.Prompt_Regular(ofSize: 12)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.Prompt_SemiBold(ofSize: 12)], for: .selected)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIApplication.shared.windows.filter({$0.isKeyWindow}).first!.safeAreaInsets.bottom > 0 {//Detect Safe Area Bottom
            tabBar.frame.size.height = 85
            for tabBarItem in (tabBar.items)!{
                tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0);
                tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 6)
            }
        }
        else{//lower
            tabBar.frame.size.height = 60
            for tabBarItem in (tabBar.items)!{
                tabBarItem.imageInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0);
                tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
            }
        }
        tabBar.frame.origin.y = view.frame.height - tabBar.frame.size.height
        
        //tabBar(tabBar, didSelect: tabBar.items!.first!)
    }
    
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//
//        let removeSelectedBackground = {
//            tabBar.subviews.filter({ $0.layer.name == "TabBackgroundView" }).first?.removeFromSuperview()
//        }
//
//        let addSelectedBackground = { (bgColour: UIColor) in
//            let tabIndex = CGFloat(tabBar.items!.firstIndex(of: item)!)
//            let tabWidth = tabBar.bounds.width / CGFloat(tabBar.items!.count)
//            let bgView = UIView(frame: CGRect(x: tabWidth * tabIndex, y: 0, width: tabWidth, height: tabBar.bounds.height))
//            bgView.backgroundColor = bgColour
//            bgView.layer.name = "TabBackgroundView"
//            tabBar.insertSubview(bgView, at: 0)
//        }
//
//        removeSelectedBackground()
//        addSelectedBackground(.tabSelected)
//    }
}

