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

final class CategoryViewController: SHKeyboardViewController {

    private let searchQueue = NSOperationQueue()
    private var searchResults = [Food]()
    private var searchBarContainer: UIView!
    private var searchCancelBtn: UIButton!
    private var searchBar: UISearchBar!
    private var searchTableView: UITableView!
    private var searchIsShown = false
    private var searchingText = ""

    private var collectionView: UICollectionView!
    private var collectionViewAnimationBlocks: [NSBlockOperation] = []
    private var fetchedResultsController: NSFetchedResultsController!

    override func loadView() {
        super.loadView()

        let app = UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self])
        app.defaultTextAttributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(18, weight: UIFontWeightMedium),
            NSForegroundColorAttributeName: "8E8E93".UIColor
        ]

        searchBarContainer = UIView()
        searchBarContainer.backgroundColor = UIColor.clearColor()
        view.addSubview(searchBarContainer)

        searchCancelBtn = UIButton(type: .System)
        searchCancelBtn.titleLabel?.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
        searchCancelBtn.setTitle(L("Annuler"), forState: .Normal)
        searchCancelBtn.setTitleColor(UIColor.appGrayColor(), forState: .Normal)
        searchCancelBtn.addTarget(self, action: #selector(CategoryViewController.cancelBtnClicked(_:)), forControlEvents: .TouchUpInside)
        searchBarContainer.addSubview(searchCancelBtn)

        searchBar = UISearchBar()
        searchBar.tintColor = UIColor.appTintColor()
        searchBar.placeholder = "Rechercher un aliment"
        let searchImg = UIImage(named: "nav_search")?.resizableImageWithCapInsets(
            UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        searchBar.backgroundImage = searchImg
        searchBar.setSearchFieldBackgroundImage(searchImg, forState: .Normal)
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 10, vertical: 0)
        searchBarContainer.addSubview(searchBar)

        searchTableView = UITableView(frame: .zero, style: .Plain)
        searchTableView.separatorStyle = .None
        searchTableView.rowHeight = 44
        searchTableView.registerClass(FoodCell.self, forCellReuseIdentifier: FoodCell.reuseIdentifier)
        searchTableView.backgroundColor = UIColor.whiteColor()
        searchTableView.tableFooterView = UIView()

        let layout = UICollectionViewFlowLayout()
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            layout.itemSize = CGSize(width: 90, height: 140)
        } else {
            layout.itemSize = CGSize(width: 110, height: 164)
        }
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 6
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 15, right: 15)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        view.addSubview(collectionView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None

        definesPresentationContext = true

        searchBar.delegate = self

        collectionView.delegate = self
        collectionView.dataSource = self

        searchTableView.delegate = self
        searchTableView.dataSource = self

        registerKeyboardNotificationsForScrollableView(searchTableView)

        prepareFechedResultsController()

        configureLayoutConstraints()
    }

    private func prepareFechedResultsController() {
        let req = FoodCategory.entityFetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        let ctx = CoreDataStack.shared.managedObjectContext
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: req,
            managedObjectContext: ctx,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)

        do {
            try fetchedResultsController.performFetch()
            collectionView.reloadData()
        } catch let err as NSError {
            print("Error while fetching foods: \(err)")
        }
    }

    private func configureLayoutConstraints() {
        searchBarContainer.snp_makeConstraints {
            $0.top.equalTo(view)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.height.equalTo(84)
        }

        searchBar.snp_makeConstraints {
            $0.left.equalTo(searchBarContainer).offset(15)
            $0.right.equalTo(searchBarContainer).offset(-15)
            $0.bottom.equalTo(searchBarContainer).offset(-10)
        }

        searchCancelBtn.snp_remakeConstraints {
            $0.right.equalTo(searchBarContainer).offset(-15)
            $0.centerY.equalTo(searchBar)
        }

        collectionView.snp_makeConstraints {
            $0.top.equalTo(searchBarContainer.snp_bottom)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.bottom.equalTo(view)
        }
    }

    deinit {
        // Cancel all block operations when VC deallocates
        for operation: NSBlockOperation in collectionViewAnimationBlocks {
            operation.cancel()
        }

        collectionViewAnimationBlocks.removeAll(keepCapacity: false)
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let isLandscape = size.height < size.width

        searchBarContainer.snp_removeConstraints()
        searchBarContainer.snp_makeConstraints {
            $0.top.equalTo(view)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            if isLandscape {
                $0.height.equalTo(64)
            } else {
                $0.height.equalTo(84)
            }
        }

        coordinator.animateAlongsideTransition({ (context) in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
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
}

// MARK: - UISearchBarDelegate
extension CategoryViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if !searchIsShown {
            searchIsShown = true
            showsCancelButton()
            showsSearchTableView()
        }
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchingText = searchText
        performSearch(searchText)
    }

    private func performSearch(searchText: String) {
        let text = sanitizeSearchText(searchText)
        searchQueue.cancelAllOperations()
        let op = NSBlockOperation {
            let req = Food.entityFetchRequest()
            req.predicate = NSPredicate(format: "name contains[cd] %@", text)
            let ctx = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            ctx.parentContext = CoreDataStack.shared.managedObjectContext
            if let objects = try! ctx.executeFetchRequest(req) as? [Food] {
                dispatch_async(dispatch_get_main_queue()) {
                    let ids = objects.map { $0.objectID }
                    self.updateTableViewWithResults(ids)
                }
            }
        }
        searchQueue.addOperation(op)
    }

    private func updateTableViewWithResults(objectIds: [NSManagedObjectID]) {
        let ctx = CoreDataStack.shared.managedObjectContext
        searchResults = objectIds.flatMap {
            ctx.objectWithID($0) as? Food
        }
        searchTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }

    private func showsCancelButton() {
        searchBar.snp_removeConstraints()
        searchBar.snp_makeConstraints {
            $0.left.equalTo(searchBarContainer).offset(15)
            $0.right.equalTo(searchCancelBtn.snp_left).offset(-10)
            $0.bottom.equalTo(searchBarContainer).offset(-10)
        }
        UIView.animateWithDuration(0.35) {
            self.searchBarContainer.layoutIfNeeded()
        }
    }

    private func hidesCancelButton() {
        searchBar.snp_removeConstraints()
        searchBar.snp_makeConstraints {
            $0.left.equalTo(searchBarContainer).offset(15)
            $0.right.equalTo(searchBarContainer).offset(-15)
            $0.bottom.equalTo(searchBarContainer).offset(-10)
        }
        UIView.animateWithDuration(0.35) {
            self.searchBarContainer.layoutIfNeeded()
        }
    }

    private func showsSearchTableView() {
        view.addSubview(searchTableView)
        searchTableView.snp_makeConstraints {
            $0.top.equalTo(searchBarContainer.snp_bottom)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.bottom.equalTo(view)
        }
        searchTableView.layoutIfNeeded()
        searchTableView.alpha = 0
        UIView.animateWithDuration(0.35) {
            self.searchTableView.alpha = 1
        }
    }

    private func hideTableView() {
        UIView.animateWithDuration(0.35, animations: {
            self.searchTableView.alpha = 0
            }, completion: { finished in
                self.searchTableView.removeFromSuperview()
        })
    }

    func cancelBtnClicked(sender: UIButton) {
        if searchIsShown {
            searchIsShown = false
            searchBar.resignFirstResponder()
            hidesCancelButton()
            hideTableView()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension CategoryViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)

        let cat = fetchedResultsController.objectAtIndexPath(indexPath) as! FoodCategory
        let foodList = FoodListViewController()
        foodList.category = cat
        navigationController?.pushViewController(foodList, animated: true)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension CategoryViewController: NSFetchedResultsControllerDelegate {
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        if type == NSFetchedResultsChangeType.Insert {
            collectionViewAnimationBlocks.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertItemsAtIndexPaths([newIndexPath!])
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.Update {
            collectionViewAnimationBlocks.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadItemsAtIndexPaths([indexPath!])
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.Move {
            collectionViewAnimationBlocks.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.Delete {
            collectionViewAnimationBlocks.append(
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
            collectionViewAnimationBlocks.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.Update {
            collectionViewAnimationBlocks.append(
                NSBlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex))
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.Delete {
            collectionViewAnimationBlocks.append(
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
            for operation: NSBlockOperation in self.collectionViewAnimationBlocks {
                operation.start()
            }
            }, completion: { (finished) -> Void in
                self.collectionViewAnimationBlocks.removeAll(keepCapacity: false)
        })
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(FoodCell.reuseIdentifier, forIndexPath: indexPath) as! FoodCell
        let food = searchResults[indexPath.row]
        cell.iconImageView.image = food.dangerImage
        cell.foodLbl.attributedText = attributedTextForSearchResult(food, searchText: searchingText)
        return cell
    }
    private func attributedTextForSearchResult(food: Food, searchText: String) -> NSAttributedString {
        let foodName = food.name ?? ""
        let attr = NSMutableAttributedString(string: foodName)

        attr.addAttribute(NSFontAttributeName,
                          value: UIFont.systemFontOfSize(18, weight: UIFontWeightMedium),
                          range: NSMakeRange(0, attr.length))

        attr.addAttribute(NSForegroundColorAttributeName,
                          value: UIColor.blackColor().colorWithAlphaComponent(0.4),
                          range: NSRange(0..<attr.length))

        let foodNameStr = NSString(string: foodName)
        let range = foodNameStr.rangeOfString(searchText,
                                              options: [.DiacriticInsensitiveSearch, .CaseInsensitiveSearch],
                                              range: NSMakeRange(0, attr.length), locale: NSLocale.currentLocale())
        if range.location != NSNotFound {
            attr.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: range)
        }

        return attr
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        searchBar.resignFirstResponder()

        let food = searchResults[indexPath.row]
        let foodController = FoodDetailViewController()
        foodController.food = food
        navigationController?.pushViewController(foodController, animated: true)
    }
}
