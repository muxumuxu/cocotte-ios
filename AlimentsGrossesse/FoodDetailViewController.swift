//
//  FoodViewController.swift
//  AlimentsGrossesse
//
//  Created by David Miotti on 21/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit

final class FoodDetailViewController: UIViewController {

    var food: Food? {
        didSet {
            if isViewLoaded() {
                configureInterfaceBasedOnFood()
            }
        }
    }

    private var backBtn: UIButton!
    private var foodNameLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        backBtn = UIButton(type: .System)
        backBtn.setImage(UIImage(named: "back_icon"), forState: .Normal)
        backBtn.addTarget(self, action: #selector(FoodDetailViewController.backBtnClicked(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(backBtn)

        foodNameLbl = UILabel()
        foodNameLbl.font = UIFont.systemFontOfSize(38, weight: UIFontWeightMedium)
        foodNameLbl.textColor = UIColor.blackColor()
        view.addSubview(foodNameLbl)

        configureLayoutConstraints()

        configureInterfaceBasedOnFood()
    }

    private func configureInterfaceBasedOnFood() {
        foodNameLbl.text = food?.name
    }

    func backBtnClicked(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }

    private func configureLayoutConstraints() {
        backBtn.snp_makeConstraints {
            $0.top.equalTo(view).offset(30)
            $0.left.equalTo(view)
            $0.width.height.equalTo(44)
        }
        foodNameLbl.snp_makeConstraints {
            $0.top.equalTo(view).offset(90)
            $0.left.equalTo(view).offset(15)
        }
    }
}
