//
//  TabBarView.swift
//  AlimentsGrossesse
//
//  Created by David Miotti on 15/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

protocol TabBarViewDelegate: class {
    func tabBarView(tabBarView: TabBarView, didSelectIndex index: Int)
}

final class TabBarView: SHCommonInitView {

    weak var delegate: TabBarViewDelegate?

    private let searchBtn = UIButton(type: .System)
    private let favBtn = UIButton(type: .System)
    private let moreBtn = UIButton(type: .System)

    private let topSeparator = UIView()

    private var stackView = UIStackView()

    override func commonInit() {
        super.commonInit()

        addSubview(stackView)
        addSubview(topSeparator)

        backgroundColor = UIColor.whiteColor()

        stackView.distribution = .FillEqually
        stackView.axis = .Horizontal

        searchBtn.setImage(UIImage(named: "search_tab"), forState: .Normal)
        searchBtn.tag = 0

        favBtn.setImage(UIImage(named: "fav_tab"), forState: .Normal)
        favBtn.tag = 1

        moreBtn.setImage(UIImage(named: "more_tab"), forState: .Normal)
        moreBtn.tag = 2

        [searchBtn, favBtn, moreBtn].forEach {
            $0.addTarget(self, action: #selector(TabBarView.tabBtnClicked(_:)), forControlEvents: .TouchUpInside)
        }

        searchBtn.tintColor = UIColor.appTintColor()
        favBtn.tintColor = UIColor.appGrayColor()
        moreBtn.tintColor = UIColor.appGrayColor()

        stackView.addArrangedSubview(searchBtn)
        stackView.addArrangedSubview(favBtn)
        stackView.addArrangedSubview(moreBtn)

        topSeparator.backgroundColor = "B2B2B2".UIColor.colorWithAlphaComponent(0.25)

        configureLayoutConstraints()
    }

    private func configureLayoutConstraints() {
        stackView.snp_makeConstraints {
            $0.edges.equalTo(self)
        }
        topSeparator.snp_makeConstraints {
            $0.top.equalTo(self)
            $0.left.equalTo(self)
            $0.right.equalTo(self)
            $0.height.equalTo(1)
        }
    }

    func tabBtnClicked(sender: UIButton) {
        let all = [searchBtn, favBtn, moreBtn]
        all.forEach { $0.tintColor = UIColor.appGrayColor() }
        sender.tintColor = UIColor.appTintColor()
        delegate?.tabBarView(self, didSelectIndex: sender.tag)
    }
}
