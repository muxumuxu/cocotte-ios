//
//  FoodViewController.swift
//  Foodancy
//
//  Created by David Miotti on 21/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers
import MessageUI
import SafariServices
import SystemConfiguration

final class FoodDetailViewController: UIViewController {

    var food: Food? {
        didSet {
            if isViewLoaded() {
                configureInterfaceBasedOnFood()
            }
        }
    }

    private var backBtn: UIButton!
    private var addToFavBtn: UIButton!

    private var scrollView: UIScrollView!
    private var scrollContainerView: UIView!

    private var foodNameLbl: UILabel!
    private var categoryImageView: UIImageView!
    private var dangerImageView: UIImageView!
    private var dangerLbl: UILabel!

    private var topSeparator: UIView!

    private var infoStackView: UIStackView!

    private var riskView: UIView!
    private var riskLbl: UILabel!
    private var riskValueBtn: UIButton!

    private var infoView: UIView!
    private var infoLbl: UILabel!
    private var infoValueLbl: UILabel!

    private var bottomSeparator: UIView!

    private var alertBtn: UIButton!
    private var warnLbl: UILabel!

    override func loadView() {
        super.loadView()

        backBtn = UIButton(type: .System)
        backBtn.setImage(UIImage(named: "back_icon"), forState: .Normal)
        backBtn.setTitle(L("Recherche"), forState: .Normal)
        backBtn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 13)
        backBtn.setTitleColor(UIColor.appGrayColor(), forState: .Normal)
        backBtn.contentHorizontalAlignment = .Left
        backBtn.titleEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 0, right: 0)
        backBtn.addTarget(self, action: #selector(FoodDetailViewController.backBtnClicked(_:)), forControlEvents: .TouchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        navigationItem.setHidesBackButton(true, animated: false)
        let backBbi = UIBarButtonItem(customView: backBtn)
        navigationItem.leftBarButtonItem = backBbi

        addToFavBtn = UIButton(type: .System)
        addToFavBtn.setImage(UIImage(named: "add_to_fav_icon"), forState: .Normal)
        addToFavBtn.contentHorizontalAlignment = .Right
        addToFavBtn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 13)
        addToFavBtn.titleEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        addToFavBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 7)
        addToFavBtn.addTarget(self, action: #selector(FoodDetailViewController.favBtnClicked(_:)), forControlEvents: .TouchUpInside)
        addToFavBtn.tintColor = UIColor.appTintColor()
        addToFavBtn.frame = CGRect(x: 0, y: 0, width: 150, height: 30)
        let rightBbi = UIBarButtonItem(customView: addToFavBtn)
        navigationItem.rightBarButtonItem = rightBbi

        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        scrollContainerView = UIView()
        scrollView.addSubview(scrollContainerView)

        categoryImageView = UIImageView()
        categoryImageView.clipsToBounds = true
        scrollContainerView.addSubview(categoryImageView)

        dangerImageView = UIImageView()
        scrollContainerView.addSubview(dangerImageView)

        foodNameLbl = UILabel()
        foodNameLbl.numberOfLines = 1
        foodNameLbl.adjustsFontSizeToFitWidth = true
        scrollContainerView.addSubview(foodNameLbl)

        dangerLbl = UILabel()
        dangerLbl.font = UIFont(name: "Avenir-Medium", size: 18)
        dangerLbl.textColor = UIColor.blackColor()
        scrollContainerView.addSubview(dangerLbl)

        infoStackView = UIStackView()
        infoStackView.axis = .Vertical
        infoStackView.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.3)
        infoStackView.spacing = 34
        scrollContainerView.addSubview(infoStackView)

        configureStackView()

        alertBtn = UIButton(type: .System)
        alertBtn.setTitle(L("Signaler cet aliment"), forState: .Normal)
        alertBtn.titleLabel?.font = UIFont(name: "Avenir-Book", size: 18)
        alertBtn.tintColor = UIColor.appBlueColor()
        alertBtn.addTarget(self, action: #selector(FoodDetailViewController.alertBtnClicked(_:)), forControlEvents: .TouchUpInside)
        scrollContainerView.addSubview(alertBtn)

        warnLbl = UILabel()
        warnLbl.font = UIFont(name: "Avenir-Book", size: 12)
        warnLbl.textColor = UIColor.appGrayColor()
        warnLbl.text = "Toutes ces recommandations sont données à titre indicatif, elles ne peuvent remplacer l'avis de votre médecin."
        warnLbl.numberOfLines = 0
        scrollContainerView.addSubview(warnLbl)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false

        view.backgroundColor = UIColor.whiteColor()

        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        configureLayoutConstraints()

        configureInterfaceBasedOnFood()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        infoValueLbl.preferredMaxLayoutWidth = infoStackView.bounds.width
    }

    func favBtnClicked(sender: UIButton) {
        if food?.favDate != nil {
            food?.favDate = nil
            addToFavBtn.tintColor = UIColor.appTintColor()
            addToFavBtn.setTitle(L("Ajouter aux favoris"), forState: .Normal)
        } else {
            food?.favDate = NSDate()
            addToFavBtn.tintColor = UIColor.appGrayColor()
            addToFavBtn.setTitle(L("Retirer des favoris"), forState: .Normal)
        }
        try! food?.managedObjectContext?.save()
    }

    func backBtnClicked(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }

    func alertBtnClicked(sender: UIButton) {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("Signaler \"\(food!.name!)\"")
        mail.setToRecipients([contactEmail])
        presentViewController(mail, animated: true, completion: nil)
    }

    func riskBtnClicked(sender: UIButton) {
        if !Reachability.isConnectedToNetwork() {
            let alert = UIAlertController(title: L("Internet not found"), message: L("Vous devez être connecté à internet pour visualiser le contenu"), preferredStyle: .Alert)
            let okAction = UIAlertAction(title: L("OK"), style: .Default, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
        } else if let url = food?.risk?.url, URL = NSURL(string: url) {
            let safari = SFSafariViewController(URL: URL)
            presentViewController(safari, animated: true, completion: nil)
        }
    }

    private func configureInterfaceBasedOnFood() {
        if let name = food?.name {
            let attr = NSMutableAttributedString(string: name)

            attr.addAttribute(
                NSFontAttributeName,
                value: UIFont(name: "Avenir-Medium", size: 38)!,
                range: NSMakeRange(0, attr.length))

            attr.addAttribute(
                NSForegroundColorAttributeName,
                value: UIColor.blackColor(),
                range: NSMakeRange(0, attr.length))

            let paragraph = NSMutableParagraphStyle()
            paragraph.lineHeightMultiple = 0.8
            attr.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: NSMakeRange(0, attr.length))

            foodNameLbl.attributedText = attr

            foodNameLbl.lineBreakMode = .ByTruncatingTail
        } else {
            foodNameLbl.attributedText = nil
        }

        if let type = food?.dangerType {
            switch type {
            case .Avoid:
                dangerLbl.text = L("À éviter")
            case .Care:
                dangerLbl.text = L("Faire attention")
            case .Good:
                dangerLbl.text = L("Autorisé")
            }
        } else {
            dangerLbl.text = nil
        }

        dangerImageView.image = food?.dangerImage

        if let imageName = food?.foodCategory?.image {
            categoryImageView.image = UIImage(named: "\(imageName)_circle")
        }

        if nilOrEmpty(food?.risk?.name) && nilOrEmpty(food?.info) {
            infoStackView.arrangedSubviews.forEach {
                infoStackView.removeArrangedSubview($0)
            }
        } else {
            if let name = food?.risk?.name where !name.isEmpty {
                riskValueBtn.setTitle(name, forState: .Normal)
                if food?.risk?.url != nil {
                    riskValueBtn.setTitleColor(UIColor.appBlueColor(), forState: .Normal)
                    riskValueBtn.userInteractionEnabled = true
                } else {
                    riskValueBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
                    riskValueBtn.userInteractionEnabled = false
                }
            } else {
                infoStackView.removeArrangedSubview(riskView)
            }

            if let info = food?.info where !info.isEmpty {
                infoValueLbl.text = info
            } else {
                infoStackView.removeArrangedSubview(infoView)
            }
        }

        if food?.favDate != nil {
            addToFavBtn.tintColor = UIColor.appGrayColor()
            addToFavBtn.setTitle(L("Retirer des favoris"), forState: .Normal)
        } else {
            addToFavBtn.tintColor = UIColor.appTintColor()
            addToFavBtn.setTitle(L("Ajouter aux favoris"), forState: .Normal)
        }

        infoStackView.setNeedsLayout()
        infoStackView.layoutIfNeeded()
        view.layoutIfNeeded()
    }

    private func nilOrEmpty(str: String?) -> Bool {
        guard let str = str else {
            return true
        }
        return str.isEmpty
    }

    private func configureLayoutConstraints() {
        scrollView.snp_makeConstraints {
            $0.edges.equalTo(view).offset(UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0))
        }

        scrollContainerView.snp_makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(view)
        }

        categoryImageView.snp_makeConstraints {
            $0.top.equalTo(scrollContainerView).offset(24)
            $0.left.equalTo(scrollContainerView).offset(14)
            $0.width.height.equalTo(92)
        }

        foodNameLbl.snp_makeConstraints {
            $0.top.greaterThanOrEqualTo(scrollContainerView).offset(10)
            $0.bottom.equalTo(categoryImageView.snp_centerY).offset(10)
            $0.left.equalTo(categoryImageView.snp_right).offset(10)
            $0.right.lessThanOrEqualTo(scrollContainerView).offset(-10)
        }

        dangerImageView.snp_makeConstraints {
            $0.top.equalTo(foodNameLbl.snp_bottom)
            $0.left.equalTo(categoryImageView.snp_right).offset(10)
            $0.width.height.equalTo(20)
        }

        dangerLbl.snp_makeConstraints {
            $0.centerY.equalTo(dangerImageView)
            $0.left.equalTo(dangerImageView.snp_right).offset(7)
        }

        infoStackView.snp_makeConstraints {
            $0.top.equalTo(categoryImageView.snp_bottom).offset(34)
            $0.left.equalTo(scrollContainerView).offset(14)
            $0.right.equalTo(scrollContainerView).offset(-14)
        }

        alertBtn.snp_makeConstraints {
            $0.top.equalTo(infoStackView.snp_bottom).offset(35)
            $0.left.equalTo(scrollContainerView).offset(14)
        }

        warnLbl.snp_makeConstraints {
            $0.top.equalTo(alertBtn.snp_bottom).offset(14)
            $0.left.equalTo(scrollContainerView).offset(14)
            $0.right.equalTo(scrollContainerView).offset(-14)

            $0.bottom.equalTo(scrollContainerView).offset(-20)
        }
    }

    private func configureStackView() {
        topSeparator = UIView()
        topSeparator.backgroundColor = UIColor.appGrayColor().colorWithAlphaComponent(0.2)
        infoStackView.addArrangedSubview(topSeparator)
        topSeparator.snp_makeConstraints {
            $0.height.equalTo(0.5)
        }

        riskView = UIView()
        riskLbl = UILabel()
        riskLbl.textColor = UIColor.appGrayColor()
        riskLbl.font = UIFont(name: "Avenir-Medium", size: 13)
        riskLbl.text = L("Risque")
        riskView.addSubview(riskLbl)
        riskLbl.snp_makeConstraints {
            $0.top.equalTo(riskView)
            $0.left.equalTo(riskView)
        }
        riskValueBtn = UIButton(type: .System)
        riskValueBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        riskValueBtn.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 18)
        riskValueBtn.addTarget(
            self,
            action: #selector(FoodDetailViewController.riskBtnClicked(_:)),
            forControlEvents: .TouchUpInside)
        riskValueBtn.titleLabel?.numberOfLines = 0
        riskView.addSubview(riskValueBtn)
        riskValueBtn.snp_makeConstraints {
            $0.top.equalTo(riskLbl.snp_bottom).offset(3)
            $0.left.equalTo(riskView)
            $0.bottom.equalTo(riskView)
        }
        infoStackView.addArrangedSubview(riskView)

        infoView = UIView()
        infoLbl = UILabel()
        infoLbl.textColor = UIColor.appGrayColor()
        infoLbl.font = UIFont(name: "Avenir-Medium", size: 13)
        infoLbl.text = L("Information")
        infoView.addSubview(infoLbl)
        infoLbl.snp_makeConstraints {
            $0.top.equalTo(infoView)
            $0.left.equalTo(infoView)
        }
        infoValueLbl = UILabel()
        infoValueLbl.textColor = UIColor.blackColor()
        infoValueLbl.font = UIFont(name: "Avenir-Medium", size: 18)
        infoValueLbl.numberOfLines = 0
        infoView.addSubview(infoValueLbl)
        infoValueLbl.snp_makeConstraints {
            $0.top.equalTo(infoLbl.snp_bottom).offset(3)
            $0.left.equalTo(infoView)
            $0.bottom.equalTo(infoView)
        }
        infoStackView.addArrangedSubview(infoView)

        bottomSeparator = UIView()
        bottomSeparator.backgroundColor = UIColor.appGrayColor().colorWithAlphaComponent(0.2)
        infoStackView.addArrangedSubview(bottomSeparator)
        bottomSeparator.snp_makeConstraints {
            $0.height.equalTo(0.5)
        }
    }
}

extension FoodDetailViewController: MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
