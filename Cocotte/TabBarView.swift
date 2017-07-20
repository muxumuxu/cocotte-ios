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
    func tabBarView(_ tabBarView: TabBarView, didShare food: Food)
    func tabBarView(_ tabBarView: TabBarView, didReport food: Food)
}

final class TabBarView: SHCommonInitView {

    weak var delegate: TabBarViewDelegate?
    
    fileprivate let topSeparator = UIView()
    fileprivate lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()

    // Global actions
    fileprivate lazy var searchBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "search_tab_selected"), for: .normal)
        button.addTarget(self, action: #selector(tabBtnClicked(_:)), for: .touchUpInside)
        button.snp.makeConstraints { $0.width.height.equalTo(44) }
        button.tag = 0
        return button
    }()
    fileprivate lazy var favBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "fav_tab"), for: .normal)
        button.addTarget(self, action: #selector(tabBtnClicked(_:)), for: .touchUpInside)
        button.snp.makeConstraints { $0.width.height.equalTo(44) }
        button.tag = 1
        return button
    }()
    fileprivate lazy var moreBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "more_tab"), for: .normal)
        button.addTarget(self, action: #selector(tabBtnClicked(_:)), for: .touchUpInside)
        button.snp.makeConstraints { $0.width.height.equalTo(44) }
        button.tag = 2
        return button
    }()
    
    // Food actions
    fileprivate lazy var toolbarShareBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "food_share_icon"), for: .normal)
        button.addTarget(self, action: #selector(shareBtnClicked(_:)), for: .touchUpInside)
        button.snp.makeConstraints { $0.width.height.equalTo(44) }
        button.contentMode = .center
        return button
    }()
    fileprivate lazy var toolbarReportBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "food_report_icon"), for: .normal)
        button.addTarget(self, action: #selector(reportBtnClicked(_:)), for: .touchUpInside)
        button.snp.makeConstraints { $0.width.height.equalTo(44) }
        button.contentMode = .center
        return button
    }()
    fileprivate var toolbarAddToFavBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "food_fav_icon"), for: .normal)
        button.addTarget(self, action: #selector(favBtnClicked(_:)), for: .touchUpInside)
        button.snp.makeConstraints { $0.width.height.equalTo(44) }
        button.contentMode = .center
        return button
    }()
    
    fileprivate var food: Food?

    override func commonInit() {
        super.commonInit()
        addSubview(stackView)
        addSubview(topSeparator)
        backgroundColor = .white
        topSeparator.backgroundColor = "B2B2B2".UIColor.withAlphaComponent(0.25)
        configureLayoutConstraints()
        configureForGlobalIcons()
    }

    fileprivate func configureLayoutConstraints() {
        stackView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }
        topSeparator.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    func configureForGlobalIcons(animated: Bool = false) {
        food = nil
        
        let configureStackView: (Void) -> Void = {
            self.stackView.arrangedSubviews.each { $0.removeFromSuperview() }
            self.stackView.spacing = 67
            self.stackView.addArrangedSubview(self.searchBtn)
            self.stackView.addArrangedSubview(self.favBtn)
            self.stackView.addArrangedSubview(self.moreBtn)
        }
        
        if (animated) {
            UIView.animate(withDuration: 0.25, animations: {
                self.stackView.transform = CGAffineTransform(translationX: 0, y: 49)
            }) { finished in
                configureStackView()
                UIView.animate(withDuration: 0.35, animations: {
                    self.stackView.transform = .identity
                })
            }
        } else {
            configureStackView()
        }
    }
    
    func configureForFood(_ food: Food) {
        self.food = food
        UIView.animate(withDuration: 0.25, animations: {
            self.stackView.transform = CGAffineTransform(translationX: 0, y: 49)
        }) { finished in
            self.stackView.arrangedSubviews.each { $0.removeFromSuperview() }
            self.stackView.spacing = 54
            self.toolbarAddToFavBtn.tintColor = food.favDate != nil ? .appTintColor() : .appGrayColor()
            self.stackView.addArrangedSubview(self.toolbarAddToFavBtn)
            self.stackView.addArrangedSubview(self.toolbarShareBtn)
            self.stackView.addArrangedSubview(self.toolbarReportBtn)
            UIView.animate(withDuration: 0.35, animations: {
                self.stackView.transform = .identity
            })
        }
    }
    
    // MARK: - Global actions
    
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
    
    // MARK: - Food actions
    
    func favBtnClicked(_ sender: UIButton) {
        guard let food = food else { return }
        let isFaving = food.favDate == nil
        if !isFaving {
            food.favDate = nil
        } else {
            food.favDate = Date()
        }
        try! food.managedObjectContext?.save()
        toolbarAddToFavBtn.tintColor = food.favDate != nil ? .appTintColor() : .appGrayColor()
        if let foodName = food.name {
            Analytics.instance.trackFav(foodName, fav: isFaving)
        }
    }
    
    func shareBtnClicked(_ sender: UIButton) {
        guard let food = food else { return }
        delegate?.tabBarView(self, didShare: food)
    }
    
    func reportBtnClicked(_ sender: UIButton) {
        guard let food = food else { return }
        delegate?.tabBarView(self, didReport: food)
    }
}
