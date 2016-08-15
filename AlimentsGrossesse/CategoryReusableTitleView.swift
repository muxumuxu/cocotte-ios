//
//  CategoryReusableTitleView.swift
//  AlimentsGrossesse
//
//  Created by David Miotti on 15/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit

final class CategoryReusableTitleView: UICollectionReusableView {
    static let reuseIdentifier = "CategoryReusableTitleView"

    private let titlLbl = UILabel()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func commonInit() {
        addSubview(titlLbl)

        titlLbl.text = "Toutes les catégories"
        titlLbl.numberOfLines = 0
        titlLbl.textColor = UIColor.appGrayColor()
        titlLbl.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
        titlLbl.snp_makeConstraints {
            $0.top.equalTo(self).offset(14)
            $0.left.equalTo(self).offset(14)
        }
    }
}
