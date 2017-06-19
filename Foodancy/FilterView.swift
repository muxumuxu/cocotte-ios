//
//  FilterView.swift
//  Foodancy
//
//  Created by David Miotti on 18/06/2017.
//  Copyright © 2017 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

final class FilterItem {
    var textValue: String?
    var selectedTextValue: String?
    
    var imageValue: UIImage?
    var selectedImageValue: UIImage?
    
    init(text: String, selectedText: String?) {
        self.textValue = text
        self.selectedTextValue = selectedText
    }
    
    init(image: UIImage, selectedImage: UIImage?) {
        self.imageValue = image
        self.selectedImageValue = selectedImage
    }
}

protocol FilterViewDelegate: class {
    func filter(view: FilterView, didSelectAt index: Int)
}

final class FilterView: SHCommonInitView {

    weak var delegate: FilterViewDelegate?
    
    var items = [FilterItem]() {
        didSet {
            setupItems()
            selectedIndex = 0
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            moveAnchorView(to: selectedIndex)
        }
    }
    
    private var itemsStackView = UIStackView()
    private var filterContainerView = UIView()
    private var anchorView = UIView()
    private var panGesture: UIPanGestureRecognizer!
    private var isDragging = false
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .white
        
        filterContainerView.layer.cornerRadius = 6
        filterContainerView.backgroundColor = "EDEDF0".UIColor
        addSubview(filterContainerView)
        
        anchorView.backgroundColor = .white
        anchorView.layer.cornerRadius = 4
        filterContainerView.addSubview(anchorView)
        
        itemsStackView.axis = .horizontal
        itemsStackView.distribution = .fillEqually
        filterContainerView.addSubview(itemsStackView)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        itemsStackView.addGestureRecognizer(panGesture)
        
        configureLayoutConstraints()
    }
    
    private func setupItems() {
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, item) in items.enumerated() {
            let btnItem = UIButton(type: .system)
            btnItem.tintColor = .clear
            btnItem.tag = index
            btnItem.addTarget(self, action: #selector(didSelectItem(_:)), for: .touchUpInside)
            if let image = item.imageValue {
                btnItem.setImage(image, for: .normal)
                btnItem.setImage(item.selectedImageValue, for: .highlighted)
                btnItem.setImage(item.selectedImageValue, for: .selected)
            } else if let text = item.textValue {
                btnItem.setTitleColor(UIColor(r: 184, g: 184, b: 184, a: 1), for: .normal)
                btnItem.setTitleColor(.black, for: .selected)
                btnItem.setTitleColor(.black, for: .highlighted)
                btnItem.setTitle(text, for: .normal)
                btnItem.setTitle(item.selectedTextValue, for: .highlighted)
                btnItem.setTitle(item.selectedTextValue, for: .selected)
            }
            itemsStackView.addArrangedSubview(btnItem)
        }
    }
    
    private func moveAnchorView(to index: Int) {
        guard itemsStackView.arrangedSubviews.count > index else {
            return
        }
        
        let btns = itemsStackView.arrangedSubviews as! [UIButton]
        btns.forEach { $0.isSelected = false }
        let selectedBtn = btns[selectedIndex]
        selectedBtn.isSelected = true
        
        anchorView.snp.remakeConstraints {
            let constraint = $0.edges.equalTo(selectedBtn)
            constraint.inset(UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.anchorView.transform = .identity
            self.layoutIfNeeded()
        })
    }
    
    func didPan(_ recognizer: UIPanGestureRecognizer) {
        guard let superView = recognizer.view?.superview else { return }
        
        // Check if we tap the anchor view
        if recognizer.state == .began {
            let touchPoint = recognizer.location(in: superView)
            isDragging = anchorView.frame.contains(touchPoint)
        }
        
        guard isDragging else { return }
        
        let translated = recognizer.translation(in: superView).x
        
        if recognizer.state == .ended {
            // Find the nearest point when releasing in order to dock it
            let targetX = anchorView.center.x + translated
            
            var nearestView = itemsStackView.arrangedSubviews.first!
            for view in itemsStackView.arrangedSubviews {
                let distance = abs(targetX - view.center.x)
                let currentDistance = abs(targetX - nearestView.center.x)
                
                if distance < currentDistance {
                    nearestView = view
                }
            }
            
            if let idx = itemsStackView.arrangedSubviews.index(of: nearestView) {
                selectedIndex = idx
            }
            
            isDragging = false
        } else {
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1,
                           options: .beginFromCurrentState, animations: {
                            self.anchorView.transform = CGAffineTransform(translationX: translated, y: 0)
            }, completion: nil)
        }
    }
    
    func didSelectItem(_ sender: UIButton) {
        selectedIndex = sender.tag
        delegate?.filter(view: self, didSelectAt: sender.tag)
    }
    
    private func configureLayoutConstraints() {
        filterContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
        itemsStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
