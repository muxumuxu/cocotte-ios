//
//  FoodViewController.swift
//  AlimentsGrossesse
//
//  Created by David Miotti on 21/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

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

    private var riskLbl = UILabel()
    private var riskValueLbl = UILabel()

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
        view.addSubview(backBtn)

        addToFavBtn = UIButton(type: .System)
        addToFavBtn.setImage(UIImage(named: "add_to_fav_icon"), forState: .Normal)
        addToFavBtn.contentHorizontalAlignment = .Right
        addToFavBtn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 13)
        addToFavBtn.titleEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        addToFavBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 7)
        addToFavBtn.addTarget(self, action: #selector(FoodDetailViewController.favBtnClicked(_:)), forControlEvents: .TouchUpInside)
        addToFavBtn.tintColor = UIColor.appTintColor()
        view.addSubview(addToFavBtn)

        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        scrollContainerView = UIView()
        scrollView.addSubview(scrollContainerView)

        categoryImageView = UIImageView()
        categoryImageView.backgroundColor = UIColor.appTintColor().colorWithAlphaComponent(0.1)
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

        riskLbl = UILabel()
        riskLbl.textColor = UIColor.appGrayColor()
        riskLbl.font = UIFont(name: "Avenir-Medium", size: 13)
        riskLbl.text = L("Risque")
        scrollContainerView.addSubview(riskLbl)

        riskValueLbl = UILabel()
        riskValueLbl.textColor = UIColor.blackColor()
        riskValueLbl.font = UIFont(name: "Avenir-Medium", size: 18)
        scrollContainerView.addSubview(riskLbl)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        categoryImageView.layer.cornerRadius = categoryImageView.frame.size.height / 2.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()

        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        configureLayoutConstraints()

        configureInterfaceBasedOnFood()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
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

    private func configureInterfaceBasedOnFood() {
        foodNameLbl.text = food?.name
        dangerLbl.text = food?.danger
        dangerImageView.image = food?.dangerImage
        riskValueLbl.text = food?.risk

        if food?.favDate != nil {
            addToFavBtn.tintColor = UIColor.appGrayColor()
            addToFavBtn.setTitle(L("Retirer des favoris"), forState: .Normal)
        } else {
            addToFavBtn.tintColor = UIColor.appTintColor()
            addToFavBtn.setTitle(L("Ajouter aux favoris"), forState: .Normal)
        }
    }

    private func configureLayoutConstraints() {
        backBtn.snp_makeConstraints {
            $0.top.equalTo(view).offset(24)
            $0.left.equalTo(view).offset(15)
            $0.height.equalTo(44)
            $0.right.equalTo(view)
        }

        addToFavBtn.snp_makeConstraints {
            $0.centerY.equalTo(backBtn).offset(-3)
            $0.width.equalTo(250)
            $0.right.equalTo(view).offset(-14)
        }

        scrollView.snp_makeConstraints {
            $0.top.equalTo(backBtn.snp_bottom)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.bottom.equalTo(view)
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
            $0.height.equalTo(1)
        }

        riskLbl.snp_makeConstraints {
            $0.top.equalTo(topSeparator.snp_bottom).offset(34)
            $0.left.equalTo(scrollContainerView).offset(14)
            $0.right.equalTo(scrollContainerView).offset(-14)
        }

        riskValueLbl.snp_makeConstraints {
            $0.top.equalTo(riskLbl).offset(3)
            $0.left.equalTo(riskLbl)

            $0.bottom.equalTo(scrollContainerView).offset(-20)
        }
    }
}
