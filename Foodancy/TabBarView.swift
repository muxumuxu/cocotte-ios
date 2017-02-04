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
    func tabBarView(_ tabBarView: TabBarView, didSelectIndex index: Int)
}

final class TabBarView: SHCommonInitView {

    weak var delegate: TabBarViewDelegate?

    fileprivate let searchBtn = UIButton(type: .system)
    fileprivate let favBtn = UIButton(type: .system)
    fileprivate let moreBtn = UIButton(type: .system)

    fileprivate let topSeparator = UIView()

    fileprivate var stackView = UIStackView()

    override func commonInit() {
        super.commonInit()

        addSubview(stackView)
        addSubview(topSeparator)

        backgroundColor = .white

        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        searchBtn.tag = 0
        favBtn.tag = 1
        moreBtn.tag = 2

        [searchBtn, favBtn, moreBtn].forEach {
            $0.addTarget(self, action: #selector(TabBarView.tabBtnClicked(_:)), for: .touchUpInside)
        }

        searchBtn.setImage(UIImage(named: "search_tab_selected"), for: UIControlState())
        favBtn.setImage(UIImage(named: "fav_tab"), for: UIControlState())
        moreBtn.setImage(UIImage(named: "more_tab"), for: UIControlState())

        stackView.addArrangedSubview(searchBtn)
        stackView.addArrangedSubview(favBtn)
        stackView.addArrangedSubview(moreBtn)

        topSeparator.backgroundColor = "B2B2B2".UIColor.withAlphaComponent(0.25)

        configureLayoutConstraints()
    }

    fileprivate func configureLayoutConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
        topSeparator.snp.makeConstraints {
            $0.top.equalTo(self)
            $0.left.equalTo(self)
            $0.right.equalTo(self)
            $0.height.equalTo(1)
        }
    }

    func tabBtnClicked(_ sender: UIButton) {
        if searchBtn.tag == sender.tag {
            searchBtn.setImage(UIImage(named: "search_tab_selected"), for: UIControlState())
        } else {
            searchBtn.setImage(UIImage(named: "search_tab"), for: UIControlState())
        }

        if favBtn.tag == sender.tag {
            favBtn.setImage(UIImage(named: "fav_tab_selected"), for: UIControlState())
        } else {
            favBtn.setImage(UIImage(named: "fav_tab"), for: UIControlState())
        }

        if moreBtn.tag == sender.tag {
            moreBtn.setImage(UIImage(named: "more_tab_selected"), for: UIControlState())
        } else {
            moreBtn.setImage(UIImage(named: "more_tab"), for: UIControlState())
        }

        delegate?.tabBarView(self, didSelectIndex: sender.tag)
    }
}
