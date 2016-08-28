//
//  MoreViewController.swift
//  Foodancy
//
//  Created by David Miotti on 26/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers
import MessageUI
import SafariServices

final class MoreViewController: UIViewController {

    enum SectionType: Int {
        case ContactUs, Rate, Share, MadeByMM, Version
        var name: String {
            switch self {
            case .ContactUs:    return "💌 Nous contacter"
            case .Rate:         return "✨ Noter l'application"
            case .Share:        return "🕊 Partager l'application"
            case .MadeByMM:     return "Made with 💚 by Muxu•Muxu"
            case .Version:      return "Ma version de Foodancy"
            }
        }
    }

    struct Section {
        let name: String
        var types = [SectionType]()
    }

    private var sections = [Section]()

    private var tableView: UITableView!

    override func loadView() {
        super.loadView()

        tableView = UITableView(frame: .zero, style: .Plain)
        tableView.separatorStyle = .None
        tableView.rowHeight = 40
        tableView.registerClass(FoodCell.self, forCellReuseIdentifier: FoodCell.reuseIdentifier)
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.clipsToBounds = true
        view.addSubview(tableView)
        tableView.snp_makeConstraints {
            $0.edges.equalTo(view)
        }

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 60))
        let footerLbl = UILabel()
        footerLbl.text = L("Toutes ces recommandations sont données à titre indicatif, elles ne peuvent remplacer l'avis de votre médecin.")
        footerLbl.numberOfLines = 0
        footerLbl.font = UIFont(name: "Avenir-Book", size: 12)
        footerLbl.textColor = UIColor.appGrayColor()
        footerView.addSubview(footerLbl)
        footerLbl.snp_makeConstraints {
            $0.left.equalTo(footerView).offset(14)
            $0.right.equalTo(footerView).offset(-14)
            $0.bottom.equalTo(footerView)
        }
        tableView.tableFooterView = footerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L("Plus")

        let support = Section(name: L("Support"), types: [.ContactUs, .Rate, .Share])
        let about = Section(name: L("À propos"), types: [.MadeByMM, .Version])
        sections = [support, about]

        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDataSource
extension MoreViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].types.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(FoodCell.reuseIdentifier, forIndexPath: indexPath) as! FoodCell

        let section = sections[indexPath.section].types[indexPath.row]

        if section == .Version {
            cell.foodLbl.text = "\(section.name) - \(appVersion())"
        } else {
            cell.foodLbl.text = section.name
        }

        cell.foodLbl.snp_removeConstraints()
        cell.foodLbl.snp_makeConstraints {
            $0.top.equalTo(cell.contentView)
            $0.bottom.equalTo(cell.contentView)
            $0.right.equalTo(cell.contentView)
            $0.left.equalTo(cell.contentView).offset(14)
        }

        return cell
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.whiteColor()
        let titleLbl = UILabel()
        titleLbl.textColor = UIColor.appGrayColor()
        titleLbl.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
        titleLbl.text = sections[section].name
        headerView.addSubview(titleLbl)
        titleLbl.snp_makeConstraints {
            $0.left.equalTo(headerView).offset(14)
            $0.bottom.equalTo(headerView).offset(-5)
        }
        return headerView
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

// MARK: - UITableViewDelegate
extension MoreViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let section = sections[indexPath.section].types[indexPath.row]

        switch section {
        case .ContactUs:
            let message = MFMailComposeViewController()
            message.mailComposeDelegate = self
            message.setToRecipients(["contact@foodancy.com"])
            presentViewController(message, animated: true, completion: nil)
        case .Rate:
            let URL = NSURL(string: "https://itunes.apple.com/fr/app/dependn-control-your-addictions/id1093903062?mt=8")!
            UIApplication.sharedApplication().openURL(URL)
        case .Share:
            let message = MFMailComposeViewController()
            message.mailComposeDelegate = self
            presentViewController(message, animated: true, completion: nil)
        case .MadeByMM:
            if !Reachability.isConnectedToNetwork() {
                let alert = UIAlertController(title: L("Internet not found"), message: L("Vous devez être connecté à internet pour visualiser le contenu"), preferredStyle: .Alert)
                let okAction = UIAlertAction(title: L("OK"), style: .Default, handler: nil)
                alert.addAction(okAction)
                presentViewController(alert, animated: true, completion: nil)
            } else if let URL = NSURL(string: "https://muxumuxu.com") {
                let safari = SFSafariViewController(URL: URL)
                presentViewController(safari, animated: true, completion: nil)
            }
        case .Version:
            break
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension MoreViewController: MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
