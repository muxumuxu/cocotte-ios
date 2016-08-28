//
//  TabBarController.swift
//  Foodancy
//
//  Created by David Miotti on 26/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit

final class TabBarController: UITabBarController, TabBarViewDelegate {

    private var tabBarView: TabBarView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.hidden = true

        tabBarView = TabBarView()
        tabBarView.delegate = self
        view.addSubview(tabBarView)

        tabBarView.snp_makeConstraints {
            $0.edges.equalTo(tabBar)
        }
    }

    func tabBarView(tabBarView: TabBarView, didSelectIndex index: Int) {
        if selectedIndex == index {
            // if it's a navigation controller, pop to rootViewController
            if let nav = viewControllers?[index] as? UINavigationController {
                nav.popToRootViewControllerAnimated(true)
            }
        } else {
            selectedIndex = index
        }
    }
}