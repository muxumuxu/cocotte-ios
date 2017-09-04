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
        activityView.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            if  let foodName = food.name,
                let categoryName = food.foodCategory?.name,
                let activityName = activityType, completed {
                Analytics.instance.trackShare(foodName, category: categoryName, media: activityName.rawValue)
            }
        }
        
        present(activityView, animated: true)
    }
    
    func tabBarView(_ tabBarView: TabBarView, didReport food: Food) {
        guard let name = food.name else {
            return
        }
        
        let subject = "Signaler \"\(name)\""

        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject(subject)
            mail.setToRecipients([contactEmail])
            present(mail, animated: true, completion: nil)
            return
        }

        if  let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let encodedEmail = contactEmail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            // Try googlemail://
            let googleMail = "googlemail://co?subject=\(encodedSubject)&to=\(encodedEmail)"
            if let url = URL(string: googleMail), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
                return
            }
            
            // Try inbox-gmail://
            let inbox = "inbox-gmail://co?subject=\(encodedSubject)&to=\(encodedEmail)"
            if let url = URL(string: inbox), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
                return
            }
        }
    }
}

extension TabBarController: MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
