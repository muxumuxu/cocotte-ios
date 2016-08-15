//
//  CategoryCell.swift
//  AlimentsGrossesse
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

        categoryImageView.contentMode = .Center
        addSubview(categoryImageView)

        categoryTitleLbl.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
        categoryTitleLbl.textColor = UIColor.appGrayColor()
        categoryTitleLbl.numberOfLines = 0
        addSubview(categoryTitleLbl)

        configureLayoutConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        categoryTitleLbl.preferredMaxLayoutWidth = bounds.width
    }

    private func configureLayoutConstraints() {
        categoryImageView.snp_makeConstraints {
            $0.top.equalTo(self)
            $0.left.equalTo(self)
            $0.right.equalTo(self)
            $0.height.equalTo(snp_width).multipliedBy(1.16)
        }

        categoryTitleLbl.snp_makeConstraints {
            $0.top.equalTo(categoryImageView.snp_bottom).offset(4)
            $0.left.equalTo(self)
            $0.right.equalTo(self)
        }
    }
}
