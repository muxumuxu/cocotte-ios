//
//  TabBarView.swift
//  AlimentsGrossesse
//
//  Created by David Miotti on 15/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

class TabBarView: SHCommonInitView {

    private var searchBtn = UIButton(type: .System)
    private var receipeBtn = UIButton(type: .System)
    private var listBtn = UIButton(type: .System)
    private var moreBtn = UIButton(type: .System)

    private var stackView = UIStackView()

    override func commonInit() {
        super.commonInit()

        addSubview(stackView)

        stackView.distribution = .FillEqually
        stackView.axis = .Horizontal

        searchBtn.setImage(UIImage(named: "search"), forState: .Normal)
        receipeBtn.setImage(UIImage(named: "receipt"), forState: .Normal)
        listBtn.setImage(UIImage(named: "list"), forState: .Normal)
        moreBtn.setImage(UIImage(named: "more"), forState: .Normal)

        searchBtn.tintColor = UIColor.appTintColor()
        receipeBtn.tintColor = UIColor.appGrayColor()
        listBtn.tintColor = UIColor.appGrayColor()
        moreBtn.tintColor = UIColor.appGrayColor()

        stackView.addArrangedSubview(searchBtn)
        stackView.addArrangedSubview(receipeBtn)
        stackView.addArrangedSubview(listBtn)
        stackView.addArrangedSubview(moreBtn)

        configureLayoutConstraints()
    }

    private func configureLayoutConstraints() {
        stackView.snp_makeConstraints {
            $0.edges.equalTo(self)
        }
    }
}
