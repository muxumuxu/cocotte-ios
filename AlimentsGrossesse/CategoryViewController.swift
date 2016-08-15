//
//  ViewController.swift
//  AlimentsGrossesse
//
//  Created by David Miotti on 15/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit

final class CategoryViewController: UIViewController {

    private var collectionView: UICollectionView!

    private var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None

        searchBar = UISearchBar()
        searchBar.searchBarStyle = .Minimal
        searchBar.placeholder = "Rechercher un aliment"
        navigationItem.titleView = searchBar

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 110, height: 164)
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 26
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 15, right: 10)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(CategoryReusableTitleView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CategoryReusableTitleView.reuseIdentifier)
        collectionView.registerClass(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)

        collectionView.snp_makeConstraints {
            $0.edges.equalTo(view)
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

        if indexPath.row == 0 {
            cell.categoryImageView.image = UIImage(named: "eggs")
            cell.categoryTitleLbl.text = "Oeufs & Laitages"
        } else if indexPath.row == 1 {
            cell.categoryImageView.image = UIImage(named: "fruits")
            cell.categoryTitleLbl.text = "Fruits & Légumes"
        } else if indexPath.row == 2 {
            cell.categoryImageView.image = UIImage(named: "see_food")
            cell.categoryTitleLbl.text = "Poissons & Fruits de mer"
        } else if indexPath.row == 3 {
            cell.categoryImageView.image = UIImage(named: "condiments")
            cell.categoryTitleLbl.text = "Condiments"
        } else if indexPath.row == 4 {
            cell.categoryImageView.image = UIImage(named: "drinks")
            cell.categoryTitleLbl.text = "Boissons"
        } else if indexPath.row == 5 {
            cell.categoryImageView.image = UIImage(named: "charcuterie")
            cell.categoryTitleLbl.text = "Charcuterie"
        } else if indexPath.row == 6 {
            cell.categoryImageView.image = UIImage(named: "desserts")
            cell.categoryTitleLbl.text = "Desserts"
        } else if indexPath.row == 7 {
            cell.categoryImageView.image = UIImage(named: "feculents")
            cell.categoryTitleLbl.text = "Féculents"
        } else if indexPath.row == 8 {
            cell.categoryImageView.image = UIImage(named: "plantes")
            cell.categoryTitleLbl.text = "Plantes"
        } else {
            cell.categoryImageView.image = UIImage(named: "eggs")
            cell.categoryTitleLbl.text = "Oeufs & Laitages"
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
