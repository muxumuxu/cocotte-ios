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

    private var stackView = UIStackView()

    override func commonInit() {
        super.commonInit()

        addSubview(stackView)

        stackView.distribution = .FillEqually
        stackView.axis = .Horizontal

        searchBtn.setImage(UIImage(named: "search_tab"), forState: .Normal)
        searchBtn.tag = 0

        favBtn.setImage(UIImage(named: "fav_tab"), forState: .Normal)
        favBtn.tag = 1

        moreBtn.setImage(UIImage(named: "more_tab"), forState: .Normal)
        moreBtn.tag = 2

        searchBtn.tintColor = UIColor.appTintColor()
        favBtn.tintColor = UIColor.appGrayColor()
        moreBtn.tintColor = UIColor.appGrayColor()

        stackView.addArrangedSubview(searchBtn)
        stackView.addArrangedSubview(favBtn)
        stackView.addArrangedSubview(moreBtn)

        configureLayoutConstraints()
    }

    private func configureLayoutConstraints() {
        stackView.snp_makeConstraints {
            $0.edges.equalTo(self)
        }
    }

    func tabBtnClicked(sender: UIButton) {
        delegate?.tabBarView(self, didSelectIndex: sender.tag)
    }
}
