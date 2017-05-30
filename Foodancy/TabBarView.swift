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

        searchBtn.setImage(UIImage(named: "search_tab_selected"), for: .normal)
        favBtn.setImage(UIImage(named: "fav_tab"), for: .normal)
        moreBtn.setImage(UIImage(named: "more_tab"), for: .normal)

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
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func tabBtnClicked(_ sender: UIButton) {
        searchBtn.setImage(#imageLiteral(resourceName: "search_tab"), for: .normal)
        favBtn.setImage(#imageLiteral(resourceName: "fav_tab"), for: .normal)
        moreBtn.setImage(#imageLiteral(resourceName: "more_tab"), for: .normal)
        
        switch sender.tag {
        case searchBtn.tag:
            searchBtn.setImage(#imageLiteral(resourceName: "search_tab_selected"), for: .normal)
        case favBtn.tag:
            favBtn.setImage(#imageLiteral(resourceName: "fav_tab_selected"), for: .normal)
        case moreBtn.tag:
            moreBtn.setImage(#imageLiteral(resourceName: "more_tab_selected"), for: .normal)
        default:
            break
        }

        delegate?.tabBarView(self, didSelectIndex: sender.tag)
    }
    
    func showActions(for food: Food) {
        
    }
    
    func hideActions() {
        
    }
}
