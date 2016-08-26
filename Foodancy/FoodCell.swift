//
//  SearchCell.swift
//  Foodancy
//
//  Created by David Miotti on 21/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

final class FoodCell: SHCommonInitTableViewCell {
    static let reuseIdentifier = "FoodCell"

    let iconImageView = UIImageView()
    let foodLbl = UILabel()

    override func commonInit() {
        super.commonInit()

        selectionStyle = .None

        foodLbl.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)

        contentView.addSubview(iconImageView)
        contentView.addSubview(foodLbl)

        configureLayoutConstraints()
    }

    private func configureLayoutConstraints() {
        iconImageView.snp_makeConstraints {
            $0.left.equalTo(contentView).offset(15)
            $0.centerY.equalTo(contentView)
            $0.width.height.equalTo(20)
        }

        foodLbl.snp_makeConstraints {
            $0.top.equalTo(contentView)
            $0.bottom.equalTo(contentView)
            $0.right.equalTo(contentView)
            $0.left.equalTo(iconImageView.snp_right).offset(5)
        }
    }
}
