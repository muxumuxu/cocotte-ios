//
//  FoodHeaderView.swift
//  Foodancy
//
//  Created by David Miotti on 05/06/2017.
//  Copyright © 2017 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

final class FoodHeaderView: SHCommonInitView {
    
    private var leftContainerView = UIView()
    private var nameLbl = UILabel()
    private var statusIcon = UIImageView()
    private var statusLbl = UILabel()
    private var imageView = UIImageView()

    override func commonInit() {
        super.commonInit()
        addSubview(imageView)
        addSubview(leftContainerView)
        imageView.clipsToBounds = true
        leftContainerView.addSubview(nameLbl)
        leftContainerView.addSubview(statusIcon)
        leftContainerView.addSubview(statusLbl)
        nameLbl.font = .systemFont(ofSize: 38, weight: UIFontWeightLight)
        nameLbl.textColor = "2B2B2C".UIColor
        nameLbl.adjustsFontSizeToFitWidth = true
        statusLbl.font = .systemFont(ofSize: 18)
        configureLayoutConstraints()
    }
    
    func configureWith(food: Food) {
        nameLbl.text = food.name
        switch food.dangerType {
        case .avoid:
            statusLbl.text = "À éviter"
            statusIcon.image = #imageLiteral(resourceName: "forbidden_icon")
            statusLbl.textColor = "F64848".UIColor
        case .care:
            statusLbl.text = "Dangereux"
            statusIcon.image = #imageLiteral(resourceName: "warning_icon")
            statusLbl.textColor = UIColor(r: 253, g: 164, b: 2, a: 1)
        case .good:
            statusLbl.text = "Autorisé"
            statusIcon.image = #imageLiteral(resourceName: "good_icon")
            statusLbl.textColor = UIColor(r: 143, g: 204, b: 38, a: 1)
        }
        if let imageName = food.foodCategory?.image {
            imageView.image = UIImage(named: "\(imageName)_circle")
        }
    }
    
    private func configureLayoutConstraints() {
        imageView.snp.makeConstraints {
            $0.top.right.bottom.equalToSuperview()
            $0.width.height.equalTo(92)
        }
        leftContainerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.right.equalTo(imageView.snp.left)
        }
        nameLbl.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview().inset(18)
        }
        statusIcon.snp.makeConstraints {
            $0.top.equalTo(nameLbl.snp.bottom).offset(2)
            $0.left.bottom.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        statusLbl.snp.makeConstraints {
            $0.left.equalTo(statusIcon.snp.right).offset(6)
            $0.centerY.equalTo(statusIcon)
            $0.right.equalToSuperview()
        }
    }
}
