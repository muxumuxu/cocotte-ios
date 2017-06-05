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
import SystemConfiguration

final class FoodDetailViewController: UIViewController {

    var food: Food? {
        didSet {
            if isViewLoaded {
                configureInterfaceBasedOnFood()
            }
        }
    }

    fileprivate var backBtn: UIButton!

    fileprivate var scrollView: UIScrollView!
    fileprivate var scrollContainerView: UIView!

    fileprivate var foodNameLbl: UILabel!
    fileprivate var categoryImageView: UIImageView!
    fileprivate var dangerImageView: UIImageView!
    fileprivate var dangerLbl: UILabel!

    fileprivate var topSeparator: UIView!

    fileprivate var infoStackView: UIStackView!

    fileprivate var riskView: UIView!
    fileprivate var riskLbl: UILabel!
    fileprivate var riskValueBtn: UIButton!

    fileprivate var infoView: UIView!
    fileprivate var infoLbl: UILabel!
    fileprivate var infoValueLbl: UILabel!

    fileprivate var bottomSeparator: UIView!

    fileprivate var warnLbl: UILabel!

    override func loadView() {
        super.loadView()
        
        title = food?.foodCategory?.name

        backBtn = UIButton(type: .system)
        backBtn.setImage(UIImage(named: "back_icon"), for: .normal)
        backBtn.setTitle(nil, for: .normal)
        backBtn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 13)
        backBtn.setTitleColor(.appGrayColor(), for: .normal)
        backBtn.contentHorizontalAlignment = .left
        backBtn.titleEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 0, right: 0)
        backBtn.addTarget(self, action: #selector(FoodDetailViewController.backBtnClicked(_:)), for: .touchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        navigationItem.setHidesBackButton(true, animated: false)
        let backBbi = UIBarButtonItem(customView: backBtn)
        navigationItem.leftBarButtonItem = backBbi

        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        scrollContainerView = UIView()
        scrollView.addSubview(scrollContainerView)

        categoryImageView = UIImageView()
        categoryImageView.clipsToBounds = true
        scrollContainerView.addSubview(categoryImageView)

        dangerImageView = UIImageView()
        scrollContainerView.addSubview(dangerImageView)

        foodNameLbl = UILabel()
        foodNameLbl.numberOfLines = 1
        foodNameLbl.adjustsFontSizeToFitWidth = true
        scrollContainerView.addSubview(foodNameLbl)

        dangerLbl = UILabel()
        dangerLbl.font = UIFont(name: "Avenir-Medium", size: 18)
        dangerLbl.textColor = .black
        scrollContainerView.addSubview(dangerLbl)

        infoStackView = UIStackView()
        infoStackView.axis = .vertical
        infoStackView.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        infoStackView.spacing = 34
        scrollContainerView.addSubview(infoStackView)

        warnLbl = UILabel()
        warnLbl.font = UIFont(name: "Avenir-Book", size: 12)
        warnLbl.textColor = UIColor.appGrayColor()
        warnLbl.text = "Toutes ces recommandations sont données à titre indicatif, elles ne peuvent remplacer l'avis de votre médecin."
        warnLbl.numberOfLines = 0
        scrollContainerView.addSubview(warnLbl)
        
        configureStackView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        configureLayoutConstraints()
        configureInterfaceBasedOnFood()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        if let tab = tabBarController as? TabBarController, let food = self.food {
            tab.tabBarView.configureForFood(food)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tab = tabBarController as? TabBarController {
            tab.tabBarView.configureForGlobalIcons(animated: true)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        infoValueLbl.preferredMaxLayoutWidth = infoStackView.bounds.width
    }
    
    // MARK: - Actions

    func backBtnClicked(_ sender: UIButton) {
        let _ = navigationController?.popViewController(animated: true)
    }

    func riskBtnClicked(_ sender: UIButton) {
        if !Reachability.isConnectedToNetwork() {
            let alert = UIAlertController(title: L("Internet not found"), message: L("Vous devez être connecté à internet pour visualiser le contenu"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: L("OK"), style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true)
        } else if let url = food?.risk?.url, let URL = URL(string: url) {
            let safari = SFSafariViewController(url: URL)
            present(safari, animated: true, completion: nil)
        }
    }

    fileprivate func configureInterfaceBasedOnFood() {
        if let name = food?.name {
            let attr = NSMutableAttributedString(string: name)
            let range = NSMakeRange(0, attr.length)
            attr.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Medium", size: 38)!, range: range)
            attr.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: range)
            foodNameLbl.attributedText = attr
        } else {
            foodNameLbl.attributedText = nil
        }

        if let type = food?.dangerType {
            switch type {
            case .avoid:
                dangerLbl.text = L("À éviter")
            case .care:
                dangerLbl.text = L("Faire attention")
            case .good:
                dangerLbl.text = L("Autorisé")
            }
        } else {
            dangerLbl.text = nil
        }

        dangerImageView.image = food?.dangerImage

        if let imageName = food?.foodCategory?.image {
            categoryImageView.image = UIImage(named: "\(imageName)_circle")
        }

        if nilOrEmpty(food?.risk?.name) && nilOrEmpty(food?.info) {
            infoStackView.arrangedSubviews.forEach {
                $0.removeFromSuperview()
            }
        } else {
            if let name = food?.risk?.name, !name.isEmpty {
                riskValueBtn.setTitle(name, for: .normal)
                if food?.risk?.url != nil {
                    riskValueBtn.setTitleColor(UIColor.appBlueColor(), for: .normal)
                    riskValueBtn.isUserInteractionEnabled = true
                } else {
                    riskValueBtn.setTitleColor(UIColor.black, for: .normal)
                    riskValueBtn.isUserInteractionEnabled = false
                }
            } else {
                riskView.removeFromSuperview()
            }

            if let info = food?.info, !info.isEmpty {
                infoValueLbl.text = info
            } else {
                infoStackView.removeFromSuperview()
            }
        }

        infoStackView.setNeedsLayout()
        infoStackView.layoutIfNeeded()
        view.layoutIfNeeded()
    }

fileprivate func nilOrEmpty(_ str: String?) -> Bool {
        guard let str = str else {
            return true
        }
        return str.isEmpty
    }

    fileprivate func configureLayoutConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }

        scrollContainerView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(view)
        }

        categoryImageView.snp.makeConstraints {
            $0.top.equalTo(scrollContainerView).offset(24)
            $0.left.equalTo(scrollContainerView).offset(14)
            $0.width.height.equalTo(92)
        }

        foodNameLbl.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(scrollContainerView).offset(10)
            $0.bottom.equalTo(categoryImageView.snp.centerY).offset(10)
            $0.left.equalTo(categoryImageView.snp.right).offset(10)
            $0.right.lessThanOrEqualTo(scrollContainerView).offset(-10)
        }

        dangerImageView.snp.makeConstraints {
            $0.top.equalTo(foodNameLbl.snp.bottom)
            $0.left.equalTo(categoryImageView.snp.right).offset(10)
            $0.width.height.equalTo(20)
        }

        dangerLbl.snp.makeConstraints {
            $0.centerY.equalTo(dangerImageView)
            $0.left.equalTo(dangerImageView.snp.right).offset(7)
        }

        infoStackView.snp.makeConstraints {
            $0.top.equalTo(categoryImageView.snp.bottom).offset(34)
            $0.left.equalTo(scrollContainerView).offset(14)
            $0.right.equalTo(scrollContainerView).offset(-14)
        }

        warnLbl.snp.makeConstraints {
            $0.top.equalTo(infoStackView.snp.bottom).offset(14)
            $0.left.equalTo(scrollContainerView).offset(14)
            $0.right.equalTo(scrollContainerView).offset(-14)

            $0.bottom.equalTo(scrollContainerView).offset(-20)
        }
    }

    fileprivate func configureStackView() {
        topSeparator = UIView()
        topSeparator.backgroundColor = UIColor.appGrayColor().withAlphaComponent(0.2)
        infoStackView.addArrangedSubview(topSeparator)
        topSeparator.snp.makeConstraints {
            $0.height.equalTo(0.5)
        }

        riskView = UIView()
        riskLbl = UILabel()
        riskLbl.textColor = UIColor.appGrayColor()
        riskLbl.font = UIFont(name: "Avenir-Medium", size: 13)
        riskLbl.text = L("Risque")
        riskView.addSubview(riskLbl)
        riskLbl.snp.makeConstraints {
            $0.top.equalTo(riskView)
            $0.left.equalTo(riskView)
        }
        riskValueBtn = UIButton(type: .system)
        riskValueBtn.setTitleColor(UIColor.black, for: .normal)
        riskValueBtn.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 18)
        riskValueBtn.addTarget(
            self,
            action: #selector(FoodDetailViewController.riskBtnClicked(_:)),
            for: .touchUpInside)
        riskValueBtn.titleLabel?.numberOfLines = 0
        riskView.addSubview(riskValueBtn)
        riskValueBtn.snp.makeConstraints {
            $0.top.equalTo(riskLbl.snp.bottom).offset(3)
            $0.left.equalTo(riskView)
            $0.bottom.equalTo(riskView)
        }
        infoStackView.addArrangedSubview(riskView)

        infoView = UIView()
        infoLbl = UILabel()
        infoLbl.textColor = UIColor.appGrayColor()
        infoLbl.font = UIFont(name: "Avenir-Medium", size: 13)
        infoLbl.text = L("Information")
        infoView.addSubview(infoLbl)
        infoLbl.snp.makeConstraints {
            $0.top.equalTo(infoView)
            $0.left.equalTo(infoView)
        }
        infoValueLbl = UILabel()
        infoValueLbl.textColor = UIColor.black
        infoValueLbl.font = UIFont(name: "Avenir-Medium", size: 18)
        infoValueLbl.numberOfLines = 0
        infoView.addSubview(infoValueLbl)
        infoValueLbl.snp.makeConstraints {
            $0.top.equalTo(infoLbl.snp.bottom).offset(3)
            $0.left.equalTo(infoView)
            $0.right.equalTo(infoView)
            $0.bottom.equalTo(infoView)
        }
        infoStackView.addArrangedSubview(infoView)

        bottomSeparator = UIView()
        bottomSeparator.backgroundColor = UIColor.appGrayColor().withAlphaComponent(0.2)
        infoStackView.addArrangedSubview(bottomSeparator)
        bottomSeparator.snp.makeConstraints {
            $0.height.equalTo(0.5)
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.infoValueLbl.preferredMaxLayoutWidth = self.view.bounds.width - 28
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

open class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
