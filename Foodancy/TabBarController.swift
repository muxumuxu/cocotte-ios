//
//  TabBarController.swift
//  Foodancy
//
//  Created by David Miotti on 26/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import MessageUI

final class TabBarController: UITabBarController, TabBarViewDelegate {

    private(set) var tabBarView: TabBarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        tabBarView = TabBarView()
        tabBarView.delegate = self
        view.addSubview(tabBarView)
        tabBarView.snp.makeConstraints { $0.edges.equalTo(tabBar) }
    }

    func tabBarView(_ tabBarView: TabBarView, didSelectIndex index: Int) {
        if selectedIndex == index {
            // if it's a navigation controller, pop to rootViewController
            if let nav = viewControllers?[index] as? UINavigationController {
                nav.popToRootViewController(animated: true)
            }
        } else {
            selectedIndex = index
        }
    }
    
    func tabBarView(_ tabBarView: TabBarView, didShare food: Food) {
        let activityProvider = FoodActivityProvider(placeholderItem: food.name!)
        activityProvider.food = food
        let url = URL(string: iTunesLink)!
        let activityView = UIActivityViewController(activityItems: [activityProvider, url], applicationActivities: nil)
        activityView.excludedActivityTypes = [
            UIActivityType.addToReadingList,
            UIActivityType.airDrop,
            UIActivityType.assignToContact,
            UIActivityType.openInIBooks,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToWeibo,
            UIActivityType.saveToCameraRoll
        ]
        
        present(activityView, animated: true)
    }
    
    func tabBarView(_ tabBarView: TabBarView, didReport food: Food) {
        guard MFMailComposeViewController.canSendMail(), let name = food.name else { return }
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("Signaler \"\(name)\"")
        mail.setToRecipients([contactEmail])
        present(mail, animated: true, completion: nil)
    }
}

extension TabBarController: MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
