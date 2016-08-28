//
//  TabBarView.swift
//  Foodancy
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
        searchBtn.tag = 0
        favBtn.tag = 1
        moreBtn.tag = 2

        [searchBtn, favBtn, moreBtn].forEach {
            $0.addTarget(self, action: #selector(TabBarView.tabBtnClicked(_:)), forControlEvents: .TouchUpInside)
        }

        searchBtn.setImage(UIImage(named: "search_tab_selected"), forState: .Normal)
        favBtn.setImage(UIImage(named: "fav_tab"), forState: .Normal)
        moreBtn.setImage(UIImage(named: "more_tab"), forState: .Normal)

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
        if searchBtn.tag == sender.tag {
            searchBtn.setImage(UIImage(named: "search_tab_selected"), forState: .Normal)
        } else {
            searchBtn.setImage(UIImage(named: "search_tab"), forState: .Normal)
        }

        if favBtn.tag == sender.tag {
            favBtn.setImage(UIImage(named: "fav_tab_selected"), forState: .Normal)
        } else {
            favBtn.setImage(UIImage(named: "fav_tab"), forState: .Normal)
        }

        if moreBtn.tag == sender.tag {
            moreBtn.setImage(UIImage(named: "more_tab_selected"), forState: .Normal)
        } else {
            moreBtn.setImage(UIImage(named: "more_tab"), forState: .Normal)
        }

        delegate?.tabBarView(self, didSelectIndex: sender.tag)
    }
}
