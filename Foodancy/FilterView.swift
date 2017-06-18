//
//  FilterView.swift
//  Foodancy
//
//  Created by David Miotti on 18/06/2017.
//  Copyright © 2017 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

class FilterItem {
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
        }
    }
    
    private var itemsStackView = UIStackView()
    private var filterContainerView = UIView()
    private var anchorView = UIView()
    
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
        addSubview(itemsStackView)
        
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
                btnItem.setTitleColor(.black, for: .normal)
                btnItem.setTitleColor(.black, for: .highlighted)
                btnItem.setTitleColor(.black, for: .selected)
                btnItem.setTitle(text, for: .normal)
                btnItem.setTitle(item.selectedTextValue, for: .highlighted)
                btnItem.setTitle(item.selectedTextValue, for: .selected)
            }
            itemsStackView.addArrangedSubview(btnItem)
        }
    }
    
    func didSelectItem(_ sender: UIButton) {
        itemsStackView.arrangedSubviews.forEach {
            ($0 as! UIButton).isSelected = false
        }
        sender.isSelected = true
        delegate?.filter(view: self, didSelectAt: sender.tag)
    }
    
    private func configureLayoutConstraints() {
        anchorView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(2)
            $0.left.equalToSuperview().offset(2)
            $0.width.equalTo(80)
        }
        itemsStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        filterContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
    }

}
