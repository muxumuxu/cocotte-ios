//
//  CategoryCell.swift
//  Foodancy
//
//  Created by David Miotti on 15/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

final class CategoryCell: SHCommonInitCollectionViewCell {

    static let reuseIdentifier = "CategoryCell"

    let categoryImageView = UIImageView()
    let categoryTitleLbl = UILabel()

    override func commonInit() {
        super.commonInit()

        categoryImageView.contentMode = .center
        addSubview(categoryImageView)

        categoryTitleLbl.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
        categoryTitleLbl.textColor = UIColor.appGrayColor()
        categoryTitleLbl.numberOfLines = 0
        addSubview(categoryTitleLbl)

        configureLayoutConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        categoryTitleLbl.preferredMaxLayoutWidth = bounds.width
    }

    fileprivate func configureLayoutConstraints() {
        categoryImageView.snp.makeConstraints {
            $0.top.equalTo(self)
            $0.left.equalTo(self)
            $0.right.equalTo(self)
            $0.height.equalTo(snp.width).multipliedBy(1.16)
        }

        categoryTitleLbl.snp.makeConstraints {
            $0.top.equalTo(categoryImageView.snp.bottom).offset(4)
            $0.left.equalTo(self)
            $0.right.equalTo(self)
        }
    }
}
