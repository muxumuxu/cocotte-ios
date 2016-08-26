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

    private var riskLbl: UILabel!
    private var riskValueBtn: UIButton!

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
        foodNameLbl.font = UIFont(name: "Avenir-Medium", size: 38)
        foodNameLbl.textColor = UIColor.blackColor()
        scrollContainerView.addSubview(foodNameLbl)

        dangerLbl = UILabel()
        dangerLbl.font = UIFont(name: "Avenir-Medium", size: 18)
        dangerLbl.textColor = UIColor.blackColor()
        scrollContainerView.addSubview(dangerLbl)

        topSeparator = UIView()
        topSeparator.backgroundColor = UIColor.appGrayColor()
        scrollContainerView.addSubview(topSeparator)

        bottomSeparator = UIView()
        bottomSeparator.backgroundColor = UIColor.appGrayColor()
        scrollContainerView.addSubview(bottomSeparator)

        riskLbl = UILabel()
        riskLbl.textColor = UIColor.appGrayColor()
        riskLbl.font = UIFont(name: "Avenir-Medium", size: 13)
        riskLbl.text = L("Risque")
        scrollContainerView.addSubview(riskLbl)

        riskValueBtn = UIButton(type: .System)
        riskValueBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        riskValueBtn.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 18)
        riskValueBtn.addTarget(self, action: #selector(FoodDetailViewController.riskBtnClicked(_:)), forControlEvents: .TouchUpInside)
        riskValueBtn.titleLabel?.numberOfLines = 0
        scrollContainerView.addSubview(riskValueBtn)

        infoLbl = UILabel()
        infoLbl.textColor = UIColor.appGrayColor()
        infoLbl.font = UIFont(name: "Avenir-Medium", size: 13)
        infoLbl.text = L("Information")
        scrollContainerView.addSubview(infoLbl)

        infoValueLbl = UILabel()
        infoValueLbl.textColor = UIColor.appGrayColor()
        infoValueLbl.numberOfLines = 0
        infoValueLbl.font = UIFont(name: "Avenir-Medium", size: 18)
        scrollContainerView.addSubview(infoValueLbl)

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

        view.backgroundColor = UIColor.whiteColor()

        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        configureLayoutConstraints()

        configureInterfaceBasedOnFood()
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
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("Reporter \"\(food!.name!)\"")
        mail.setToRecipients(["contact@foodancy.com"])
        presentViewController(mail, animated: true, completion: nil)
    }

    func riskBtnClicked(sender: UIButton) {
        if let url = food?.risk?.url, URL = NSURL(string: url) {
            let safari = SFSafariViewController(URL: URL)
            presentViewController(safari, animated: true, completion: nil)
        }
    }

    private func configureInterfaceBasedOnFood() {
        foodNameLbl.text = food?.name

        if let type = food?.dangerType {
            switch type {
            case .Avoid:
                dangerLbl.text = L("À éviter")
            case .Care:
                dangerLbl.text = L("Faire attention")
            case .Good:
                dangerLbl.text = L("Aucun")
            }
        } else {
            dangerLbl.text = nil
        }

        dangerImageView.image = food?.dangerImage

        if let imageName = food?.foodCategory?.image {
            categoryImageView.image = UIImage(named: "\(imageName)_circle")
        }

        if food?.risk?.url != nil {
            riskValueBtn.setTitleColor(UIColor.appBlueColor(), forState: .Normal)
            riskValueBtn.userInteractionEnabled = true
        } else {
            riskValueBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            riskValueBtn.userInteractionEnabled = false
        }
        riskValueBtn.setTitle(food?.risk?.name, forState: .Normal)

        infoValueLbl.text = food?.info

        if food?.favDate != nil {
            addToFavBtn.tintColor = UIColor.appGrayColor()
            addToFavBtn.setTitle(L("Retirer des favoris"), forState: .Normal)
        } else {
            addToFavBtn.tintColor = UIColor.appTintColor()
            addToFavBtn.setTitle(L("Ajouter aux favoris"), forState: .Normal)
        }
    }

    private func configureLayoutConstraints() {
        scrollView.snp_makeConstraints {
            $0.edges.equalTo(view)
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
            $0.centerY.equalTo(categoryImageView).offset(-10)
            $0.left.equalTo(categoryImageView.snp_right).offset(10)
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

        topSeparator.snp_makeConstraints {
            $0.top.equalTo(categoryImageView.snp_bottom).offset(34)
            $0.left.equalTo(scrollContainerView).offset(14)
            $0.right.equalTo(scrollContainerView).offset(-14)
            $0.height.equalTo(0.5)
        }

        riskLbl.snp_makeConstraints {
            $0.top.equalTo(topSeparator.snp_bottom).offset(34)
            $0.left.equalTo(scrollContainerView).offset(14)
            $0.right.equalTo(scrollContainerView).offset(-14)
        }

        riskValueBtn.snp_makeConstraints {
            $0.top.equalTo(riskLbl.snp_bottom).offset(3)
            $0.left.equalTo(riskLbl)
            $0.right.lessThanOrEqualTo(scrollContainerView).offset(-14)
        }

        infoLbl.snp_makeConstraints {
            $0.top.equalTo(riskValueBtn.snp_bottom).offset(22)
            $0.left.equalTo(scrollContainerView).offset(14)
            $0.right.equalTo(scrollContainerView).offset(-14)
        }

        infoValueLbl.snp_makeConstraints {
            $0.top.equalTo(infoLbl.snp_bottom).offset(3)
            $0.left.equalTo(infoLbl)
            $0.right.lessThanOrEqualTo(scrollContainerView).offset(-14)
        }

        bottomSeparator.snp_makeConstraints {
            $0.top.equalTo(infoValueLbl.snp_bottom).offset(32)
            $0.left.equalTo(topSeparator)
            $0.right.equalTo(topSeparator)
            $0.height.equalTo(0.5)
        }

        alertBtn.snp_makeConstraints {
            $0.top.equalTo(bottomSeparator.snp_bottom).offset(35)
            $0.left.equalTo(scrollContainerView).offset(14)
        }

        warnLbl.snp_makeConstraints {
            $0.top.equalTo(alertBtn.snp_bottom).offset(14)
            $0.left.equalTo(scrollContainerView).offset(14)
            $0.right.equalTo(scrollContainerView).offset(-14)

            $0.bottom.equalTo(scrollContainerView).offset(-20)
        }
    }
}

extension FoodDetailViewController: MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
