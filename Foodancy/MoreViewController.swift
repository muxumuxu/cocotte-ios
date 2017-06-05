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
        case contactUs, rate, share, madeByMM, version
        var name: String {
            switch self {
            case .contactUs:    return "💌 Nous contacter"
            case .rate:         return "✨ Noter l'application"
            case .share:        return "🕊 Partager l'application"
            case .madeByMM:     return "Made with 💚 by Muxu•Muxu"
            case .version:      return "Ma version de Foodancy"
            }
        }
    }

    struct Section {
        let name: String
        var types = [SectionType]()
    }

    fileprivate var sections = [Section]()

    fileprivate var tableView: UITableView!

    override func loadView() {
        super.loadView()

        tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.rowHeight = 40
        tableView.register(FoodCell.self, forCellReuseIdentifier: FoodCell.reuseIdentifier)
        tableView.backgroundColor = UIColor.white
        tableView.clipsToBounds = true
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 60))
        let footerLbl = UILabel()
        footerLbl.text = L("Toutes ces recommandations sont données à titre indicatif, elles ne peuvent remplacer l'avis de votre médecin.")
        footerLbl.numberOfLines = 0
        footerLbl.font = UIFont(name: "Avenir-Book", size: 12)
        footerLbl.textColor = UIColor.appGrayColor()
        footerView.addSubview(footerLbl)
        footerLbl.snp.makeConstraints {
            $0.left.equalTo(footerView).offset(14)
            $0.right.equalTo(footerView).offset(-14)
            $0.bottom.equalTo(footerView)
        }
        tableView.tableFooterView = footerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L("Plus")

        let support = Section(name: L("Support"), types: [.contactUs, .rate, .share])
        let about = Section(name: L("À propos"), types: [.madeByMM, .version])
        sections = [support, about]

        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDataSource
extension MoreViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].types.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FoodCell.reuseIdentifier, for: indexPath) as! FoodCell

        let section = sections[indexPath.section].types[indexPath.row]

        if section == .version {
            cell.foodLbl.text = "\(section.name) - \(appVersion())"
        } else {
            cell.foodLbl.text = section.name
        }

        cell.foodLbl.snp.removeConstraints()
        cell.foodLbl.snp.makeConstraints {
            $0.top.equalTo(cell.contentView)
            $0.bottom.equalTo(cell.contentView)
            $0.right.equalTo(cell.contentView)
            $0.left.equalTo(cell.contentView).offset(14)
        }

        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        let titleLbl = UILabel()
        titleLbl.textColor = UIColor.appGrayColor()
        titleLbl.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
        titleLbl.text = sections[section].name
        headerView.addSubview(titleLbl)
        titleLbl.snp.makeConstraints {
            $0.left.equalTo(headerView).offset(14)
            $0.bottom.equalTo(headerView).offset(-5)
        }
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

// MARK: - UITableViewDelegate
extension MoreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = sections[indexPath.section].types[indexPath.row]

        switch section {
        case .contactUs:
            let message = MFMailComposeViewController()
            message.mailComposeDelegate = self
            message.setToRecipients([contactEmail])
            present(message, animated: true, completion: nil)
        case .rate:
            if let URL = URL(string: iTunesLink) {
                UIApplication.shared.openURL(URL)
            }
        case .share:
            if let URL = URL(string: iTunesLink) {
                let activity = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
                present(activity, animated: true, completion: nil)
            }
        case .madeByMM:
            if let URL = URL(string: "https://muxumuxu.com") {
                let safari = SFSafariViewController(url: URL)
                present(safari, animated: true)
            }
        case .version:
            break
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension MoreViewController: MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
