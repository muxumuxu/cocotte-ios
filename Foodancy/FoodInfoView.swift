//
//  FoodInfoView.swift
//  Foodancy
//
//  Created by David Miotti on 05/06/2017.
//  Copyright © 2017 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

protocol FoodInfoViewDelegate {
    func foodInfoView(view: FoodInfoView, didSelect food: Food)
}

final class FoodInfoView: SHCommonInitView {
    private let titleLbl = UILabel()
    private let contentLbl = UILabel()
    private let moreBtn = UIButton(type: .system)
    
    var delegate: FoodInfoViewDelegate?
    
    var food: Food? {
        didSet {
            if let info = food?.info, !info.isEmpty {
                contentLbl.text = info
            } else {
                contentLbl.text = "Aucune"
            }
            
            moreBtn.isHidden = food?.risk?.url == nil
            moreBtn.snp.updateConstraints { $0.height.equalTo(moreBtn.isHidden ? 0 : 18) }
        }
    }
    
    override func commonInit() {
        super.commonInit()
        addSubview(titleLbl)
        addSubview(contentLbl)
        addSubview(moreBtn)
        
        titleLbl.font = .systemFont(ofSize: 18, weight: UIFontWeightMedium)
        titleLbl.text = "Information"
        
        contentLbl.font = .systemFont(ofSize: 18)
        contentLbl.textColor = "2B2B2C".UIColor.withAlphaComponent(0.6)
        contentLbl.numberOfLines = 0
        
        moreBtn.setTitle("En savoir plus", for: .normal)
        moreBtn.setTitleColor("007CFF".UIColor, for: .normal)
        moreBtn.titleLabel?.font = .systemFont(ofSize: 18)
        moreBtn.contentHorizontalAlignment = .left
        moreBtn.addTarget(self, action: #selector(moreBtnClicked(_:)), for: .touchUpInside)
        
        configureLayoutConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentLbl.preferredMaxLayoutWidth = bounds.size.width
    }
    
    func moreBtnClicked(_ sender: UIButton) {
        guard let food = food else { return }
        delegate?.foodInfoView(view: self, didSelect: food)
    }
    
    private func configureLayoutConstraints() {
        titleLbl.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
        contentLbl.snp.makeConstraints {
            $0.top.equalTo(titleLbl.snp.bottom).offset(2)
            $0.left.right.equalToSuperview()
        }
        moreBtn.snp.makeConstraints {
            $0.top.equalTo(contentLbl.snp.bottom).offset(4)
            $0.height.equalTo(0)
            $0.left.right.bottom.equalToSuperview()
        }
    }
}
