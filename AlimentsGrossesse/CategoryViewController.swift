//
//  ViewController.swift
//  AlimentsGrossesse
//
//  Created by David Miotti on 15/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers
import CoreData

final class CategoryViewController: UIViewController {

    private var collectionView: UICollectionView!

    private var tabBarView = TabBarView()

    private var searchBar: UISearchBar!

    private var blockOperations: [NSBlockOperation] = []

    private var fetchedResultsController: NSFetchedResultsController!

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

        let req = FoodCategory.entityFetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        let ctx = CoreDataStack.shared.managedObjectContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: req, managedObjectContext: ctx, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        configureLayoutConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        do {
            try fetchedResultsController.performFetch()

            collectionView.reloadData()
        } catch let err as NSError {
            print("Error while fetching foods: \(err)")
        }
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

    deinit {
        // Cancel all block operations when VC deallocates
        for operation: NSBlockOperation in blockOperations {
            operation.cancel()
        }

        blockOperations.removeAll(keepCapacity: false)
    }
}

extension CategoryViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CategoryCell.reuseIdentifier, forIndexPath: indexPath) as! CategoryCell

        let category = fetchedResultsController.objectAtIndexPath(indexPath) as! FoodCategory

        cell.categoryTitleLbl.text = category.name

        if let imageName = category.image {
            let image = UIImage(named: imageName)

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
        } else {
            cell.categoryImageView.image = nil
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

extension CategoryViewController: NSFetchedResultsControllerDelegate {
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        if type == NSFetchedResultsChangeType.Insert {
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertItemsAtIndexPaths([newIndexPath!])
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.Update {
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadItemsAtIndexPaths([indexPath!])
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.Move {
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.Delete {
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteItemsAtIndexPaths([indexPath!])
                    }
                    })
            )
        }
    }

    // In the did change section method:
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        if type == NSFetchedResultsChangeType.Insert {
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.Update {
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.Delete {
            blockOperations.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        }
    }

    // And finally, in the did controller did change content method:
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView!.performBatchUpdates({ () -> Void in
            for operation: NSBlockOperation in self.blockOperations {
                operation.start()
            }
            }, completion: { (finished) -> Void in
                self.blockOperations.removeAll(keepCapacity: false)
        })
    }
}
