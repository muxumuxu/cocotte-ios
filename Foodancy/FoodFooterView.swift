//
//  FoodFooterView.swift
//  Foodancy
//
//  Created by David Miotti on 05/06/2017.
//  Copyright © 2017 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

final class FoodFooterView: SHCommonInitView {
    private let separatorView = UIView()
    private let textLbl = UILabel()

    override func commonInit() {
        super.commonInit()
        addSubview(textLbl)
        addSubview(separatorView)
        separatorView.backgroundColor = "8E8E93".UIColor.withAlphaComponent(0.1)
        textLbl.text = "Toutes ces recommandations sont données à titre indicatif, elles ne peuvent remplacer l'avis de votre médecin."
        textLbl.font = .systemFont(ofSize: 12)
        textLbl.textColor = UIColor.black.withAlphaComponent(0.6)
        textLbl.numberOfLines = 0
        configureLayoutConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLbl.preferredMaxLayoutWidth = bounds.size.width
    }
    
    private func configureLayoutConstraints() {
        separatorView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(1)
        }
        textLbl.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(28)
            $0.left.right.bottom.equalToSuperview()
        }
    }

}
