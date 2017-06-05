//
//  FoodViewController.swift
//  Foodancy
//
//  Created by David Miotti on 21/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers
import SafariServices

final class FoodDetailViewController: UIViewController {
    var food: Food!
    
    private var backBtn: UIButton!
    
    private var scrollView: UIScrollView!
    private var scrollContainerView: UIView!
    private var foodHeaderView: FoodHeaderView!
    private var riskView: RiskView!
    private var infoView: FoodInfoView!
    private var footerView: FoodFooterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = food.foodCategory?.name
        
        view.backgroundColor = .white
        
        backBtn = UIButton(type: .system)
        backBtn.addTarget(self, action: #selector(backBtnClicked(_:)), for: .touchUpInside)
        backBtn.setImage(#imageLiteral(resourceName: "back_icon"), for: .normal)
        backBtn.titleEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 0, right: 0)
        backBtn.contentHorizontalAlignment = .left
        backBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollContainerView = UIView()
        scrollView.addSubview(scrollContainerView)
        
        foodHeaderView = FoodHeaderView()
        scrollContainerView.addSubview(foodHeaderView)
        
        riskView = RiskView()
        riskView.delegate = self
        scrollContainerView.addSubview(riskView)
        
        infoView = FoodInfoView()
        infoView.delegate = self
        scrollContainerView.addSubview(infoView)
        
        footerView = FoodFooterView()
        scrollContainerView.addSubview(footerView)
        
        configureLayoutConstraints()
        
        foodHeaderView.configureWith(food: food)
        riskView.food = food
        infoView.food = food
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tab = tabBarController as? TabBarController {
            tab.tabBarView.configureForFood(food)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tab = tabBarController as? TabBarController {
            tab.tabBarView.configureForGlobalIcons(animated: true)
        }
    }
    
    func backBtnClicked(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func configureLayoutConstraints() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        foodHeaderView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.left.equalToSuperview().offset(18)
            $0.right.equalToSuperview().inset(18)
            $0.height.equalTo(92)
        }
        riskView.snp.makeConstraints {
            $0.top.equalTo(foodHeaderView.snp.bottom).offset(28)
            $0.left.equalToSuperview().offset(18)
            $0.right.equalToSuperview().inset(18)
        }
        infoView.snp.makeConstraints {
            $0.top.equalTo(riskView.snp.bottom).offset(28)
            $0.left.equalToSuperview().offset(18)
            $0.right.equalToSuperview().inset(18)
        }
        footerView.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(28)
            $0.left.equalToSuperview().offset(18)
            $0.right.equalToSuperview().inset(18)
            
            $0.bottom.equalTo(scrollContainerView).inset(28)
        }
    }
}

// MARK: - RiskViewDelegate
extension FoodDetailViewController: RiskViewDelegate {
    func riskView(view: RiskView, didSelect food: Food) {
        guard let urlString = food.risk?.url,
            let url = URL(string: urlString) else { return }
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
}

// MARK: - FoodInfoViewDelegate
extension FoodDetailViewController: FoodInfoViewDelegate {
    func foodInfoView(view: FoodInfoView, didSelect food: Food) {
        guard let urlString = food.risk?.url, let url = URL(string: urlString) else {
            return
        }
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
}
