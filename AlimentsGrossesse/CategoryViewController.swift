//
//  ViewController.swift
//  AlimentsGrossesse
//
//  Created by David Miotti on 15/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers

final class CategoryViewController: UIViewController {

    private var collectionView: UICollectionView!

    private var tabBarView = TabBarView()

    private var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None

        searchBar = UISearchBar()
        searchBar.tintColor = UIColor.appTintColor()
        searchBar.searchBarStyle = .Minimal
        searchBar.placeholder = "Rechercher un aliment"
        navigationItem.titleView = searchBar

        let layout = UICollectionViewFlowLayout()
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            layout.itemSize = CGSize(width: 90, height: 140)
        } else {
            layout.itemSize = CGSize(width: 110, height: 164)
        }
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 6
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 15, right: 10)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(CategoryReusableTitleView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CategoryReusableTitleView.reuseIdentifier)
        collectionView.registerClass(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)

        view.addSubview(tabBarView)

        configureLayoutConstraints()
    }

    private func configureLayoutConstraints() {
        collectionView.snp_makeConstraints {
            $0.top.equalTo(view)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.bottom.equalTo(tabBarView.snp_top)
        }

        tabBarView.snp_makeConstraints {
            $0.bottom.equalTo(view)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.height.equalTo(50)
        }
    }
}

extension CategoryViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CategoryCell.reuseIdentifier, forIndexPath: indexPath) as! CategoryCell

        let image: UIImage?
        if indexPath.row == 0 {
            image = UIImage(named: "eggs")
            cell.categoryTitleLbl.text = "Oeufs & Laitages"
        } else if indexPath.row == 1 {
            image = UIImage(named: "fruits")
            cell.categoryTitleLbl.text = "Fruits & Légumes"
        } else if indexPath.row == 2 {
            image = UIImage(named: "see_food")
            cell.categoryTitleLbl.text = "Poissons & Fruits de mer"
        } else if indexPath.row == 3 {
            image = UIImage(named: "condiments")
            cell.categoryTitleLbl.text = "Condiments"
        } else if indexPath.row == 4 {
            image = UIImage(named: "drinks")
            cell.categoryTitleLbl.text = "Boissons"
        } else if indexPath.row == 5 {
            image = UIImage(named: "charcuterie")
            cell.categoryTitleLbl.text = "Charcuterie"
        } else if indexPath.row == 6 {
            image = UIImage(named: "desserts")
            cell.categoryTitleLbl.text = "Desserts"
        } else if indexPath.row == 7 {
            image = UIImage(named: "feculents")
            cell.categoryTitleLbl.text = "Féculents"
        } else if indexPath.row == 8 {
            image = UIImage(named: "plantes")
            cell.categoryTitleLbl.text = "Plantes"
        } else {
            image = UIImage(named: "eggs")
            cell.categoryTitleLbl.text = "Oeufs & Laitages"
        }

        if let image = image where DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            // Apply a scale factor
            let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.81, 0.81))

            let scale: CGFloat = UIScreen.mainScreen().scale

            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            image.drawInRect(CGRect(origin: CGPoint.zero, size: size))

            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            cell.categoryImageView.image = scaledImage
        } else {
            cell.categoryImageView.image = image
        }

        return cell
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: CategoryReusableTitleView.reuseIdentifier, forIndexPath: indexPath)
        return view
    }
}

extension CategoryViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
}

extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 34)
    }
}
