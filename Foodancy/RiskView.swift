//
//  RiskView.swift
//  Foodancy
//
//  Created by David Miotti on 05/06/2017.
//  Copyright © 2017 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

protocol RiskViewDelegate: class {
    func riskView(view: RiskView, didSelect food: Food)
}

final class RiskView: SHCommonInitView {
    
    private let titleLbl = UILabel()
    private let contentBtn = UIButton(type: .system)
    
    var delegate: RiskViewDelegate?
    
    var food: Food? {
        didSet {
            if let risk = food?.risk {
                contentBtn.setTitle(risk.name, for: .normal)
                if risk.url != nil {
                    contentBtn.setTitleColor("007CFF".UIColor, for: .normal)
                    contentBtn.isUserInteractionEnabled = true
                } else {
                    contentBtn.setTitleColor("2B2B2C".UIColor.withAlphaComponent(0.6), for: .normal)
                    contentBtn.isUserInteractionEnabled = false
                }
            } else {
                contentBtn.setTitle("Aucun", for: .normal)
                contentBtn.setTitleColor("2B2B2C".UIColor.withAlphaComponent(0.6), for: .normal)
                contentBtn.isUserInteractionEnabled = false
            }
        }
    }
    
    override func commonInit() {
        super.commonInit()
        addSubview(titleLbl)
        addSubview(contentBtn)
        
        titleLbl.textColor = .black
        titleLbl.font = .systemFont(ofSize: 18, weight: UIFontWeightMedium)
        titleLbl.text = "Risque"
        
        contentBtn.titleLabel?.font = .systemFont(ofSize: 18)
        contentBtn.contentHorizontalAlignment = .left
        contentBtn.addTarget(self, action: #selector(riskBtnClicked(_:)), for: .touchUpInside)
        
        configureLayoutConstraints()
    }
    
    func riskBtnClicked(_ sender: UIButton) {
        guard let food = food else { return }
        delegate?.riskView(view: self, didSelect: food)
    }
    
    private func configureLayoutConstraints() {
        titleLbl.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
        contentBtn.snp.makeConstraints {
            $0.top.equalTo(titleLbl.snp.bottom).offset(2)
            $0.height.equalTo(23)
            $0.left.right.bottom.equalToSuperview()
        }
    }
}
