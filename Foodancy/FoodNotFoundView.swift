//
//  FoodNotFoundView.swift
//  Foodancy
//
//  Created by David Miotti on 26/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

final class FoodNotFoundView: SHCommonInitView {

    fileprivate let textLbl = UILabel()

    override func commonInit() {
        super.commonInit()

        textLbl.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        textLbl.numberOfLines = 0
        textLbl.text = "Your search - bi - did not match any aliments.\n\nSuggestions:\n\\u2022Make sure that all words are spelled correctly."
        addSubview(textLbl)
        textLbl.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
    }
}
