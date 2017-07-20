//
//  FavEmptyView.swift
//  Foodancy
//
//  Created by David Miotti on 28/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

final class FavEmptyView: SHCommonInitView {

    override func commonInit() {
        super.commonInit()

        let imageView = UIImageView(image: UIImage(named: "fav_empty"))
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.centerX.equalTo(self)
            $0.centerY.equalTo(self).offset(-50)
        }

        let titleLbl = UILabel()
        titleLbl.numberOfLines = 0
        titleLbl.textAlignment = .center
        titleLbl.text = "Retrouvez ici les aliments que vous avez ajouté en favoris."
        titleLbl.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        addSubview(titleLbl)

        titleLbl.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.centerX.equalTo(self)
            $0.left.greaterThanOrEqualTo(self).offset(15)
            $0.right.lessThanOrEqualTo(self).offset(-15)
        }
    }
}
