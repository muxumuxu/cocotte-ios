//
//  ViewController.swift
//  Foodancy
//
//  Created by David Miotti on 15/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers
import CoreData

final class CategoryViewController: SHKeyboardViewController {

    fileprivate let searchQueue = OperationQueue()
    fileprivate var searchResults = [Food]()
    fileprivate var searchBarContainer: UIView!
    fileprivate var searchCancelBtn: UIButton!
    fileprivate var searchBar: UISearchBar!
    fileprivate var searchTableView: UITableView!
    fileprivate var searchIsShown = false
    fileprivate var searchingText = ""

    fileprivate var collectionView: UICollectionView!
    fileprivate var collectionViewAnimationBlocks: [BlockOperation] = []
    fileprivate var fetchedResultsController: NSFetchedResultsController<FoodCategory>!

    fileprivate var cachedImages = NSMutableDictionary()
    
    private func customizeNavigationBar() {
        let navBorder = UIView()
        navBorder.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        navigationController?.navigationBar.addSubview(navBorder)
        navBorder.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium),
            NSForegroundColorAttributeName: "99999E".UIColor
        ]
    }

    override func loadView() {
        super.loadView()

        searchBarContainer = UIView()
        searchBarContainer.backgroundColor = UIColor.clear
        view.addSubview(searchBarContainer)

        searchCancelBtn = UIButton(type: .system)
        searchCancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
        searchCancelBtn.setTitle(L("Annuler"), for: .normal)
        searchCancelBtn.setTitleColor(UIColor.appGrayColor(), for: .normal)
        searchCancelBtn.addTarget(self, action: #selector(CategoryViewController.cancelBtnClicked(_:)), for: .touchUpInside)
        searchBarContainer.addSubview(searchCancelBtn)

        searchBar = UISearchBar()
        searchBar.tintColor = UIColor.appTintColor()
        searchBar.placeholder = "Rechercher un aliment"
        let searchImg = UIImage(named: "nav_search")?.resizableImage(
            withCapInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        searchBar.backgroundImage = searchImg
        searchBar.setSearchFieldBackgroundImage(searchImg, for: .normal)
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 10, vertical: 0)
        searchBarContainer.addSubview(searchBar)

        searchTableView = UITableView(frame: .zero, style: .plain)
        searchTableView.separatorStyle = .none
        searchTableView.rowHeight = 44
        searchTableView.register(FoodCell.self, forCellReuseIdentifier: FoodCell.reuseIdentifier)
        searchTableView.backgroundColor = UIColor.white
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
        collectionView.backgroundColor = UIColor.white
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        view.addSubview(collectionView)
        
        customizeNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []

        definesPresentationContext = true

        searchBar.delegate = self

        collectionView.delegate = self
        collectionView.dataSource = self

        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        registerKeyboardNotifications(for: searchTableView)

        prepareFechedResultsController()

        configureLayoutConstraints()
    }

    fileprivate func prepareFechedResultsController() {
        let req = NSFetchRequest<FoodCategory>(entityName: FoodCategory.entityName)
        req.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        let ctx = CoreDataStack.shared.managedObjectContext
        fetchedResultsController = NSFetchedResultsController<FoodCategory>(
            fetchRequest: req,
            managedObjectContext: ctx,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)

        do {
            try fetchedResultsController.performFetch()

            if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
                // rescale all category images
                DispatchQueue.global().async {
                    if let cats = self.fetchedResultsController.fetchedObjects {
                        for cat in cats {
                            if let name = cat.name, let imageName = cat.image, let img = UIImage(named: imageName) {
                                let scaled = self.scaleForLowerScreenDevice(img)
                                self.cachedImages.setObject(scaled, forKey: NSString(string: name))
                            }
                        }
                    }
                    DispatchQueue.main.async(execute: self.collectionView.reloadData)
                }
            } else {
                collectionView.reloadData()
            }
        } catch let err as NSError {
            print("Error while fetching foods: \(err)")
        }
    }

    fileprivate func configureLayoutConstraints() {
        searchBarContainer.snp.makeConstraints {
            $0.top.equalTo(view)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.height.equalTo(84)
        }

        searchBar.snp.makeConstraints {
            $0.left.equalTo(searchBarContainer).offset(15)
            $0.right.equalTo(searchBarContainer).offset(-15)
            $0.bottom.equalTo(searchBarContainer).offset(-10)
        }

        searchCancelBtn.snp.remakeConstraints {
            $0.right.equalTo(searchBarContainer).offset(-15)
            $0.centerY.equalTo(searchBar)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBarContainer.snp.bottom)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.bottom.equalTo(view)
        }
    }

    deinit {
        // Cancel all block operations when VC deallocates
        for operation: BlockOperation in collectionViewAnimationBlocks {
            operation.cancel()
        }

        collectionViewAnimationBlocks.removeAll(keepingCapacity: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let isLandscape = size.height < size.width
        
        searchBarContainer.snp.removeConstraints()
        searchBarContainer.snp.makeConstraints {
            $0.top.equalTo(view)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            if isLandscape {
                $0.height.equalTo(64)
            } else {
                $0.height.equalTo(84)
            }
        }
        coordinator.animate(alongsideTransition: { context in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension CategoryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as! CategoryCell

        let category = fetchedResultsController.object(at: indexPath) 

        cell.categoryTitleLbl.text = category.name

        if let imageName = category.image, let name = category.name {

            if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
                if let img = cachedImages.object(forKey: name) as? UIImage {
                    cell.categoryImageView.image = img
                } else if let image = UIImage(named: imageName) {
                    let img = scaleForLowerScreenDevice(image)
                    cachedImages.setObject(img, forKey: name as NSCopying)
                    cell.categoryImageView.image = img
                }
            } else {
                cell.categoryImageView.image = UIImage(named: imageName)
            }
        } else {
            cell.categoryImageView.image = nil
        }

        return cell
    }

    fileprivate func scaleForLowerScreenDevice(_ image: UIImage) -> UIImage {
        let size = image.size.applying(CGAffineTransform(scaleX: 0.81, y: 0.81))
        let scale: CGFloat = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}

// MARK: - UISearchBarDelegate
extension CategoryViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !searchIsShown {
            searchBar.placeholder = "Rechercher"
            searchIsShown = true
            showsCancelButton()
            showsSearchTableView()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchingText = searchText
        performSearch(searchText)
    }

    fileprivate func performSearch(_ searchText: String) {
        let text = sanitizeSearchText(searchText)
        searchQueue.cancelAllOperations()
        let op = BlockOperation {
            let req = NSFetchRequest<Food>(entityName: Food.entityName)
            req.predicate = NSPredicate(format: "name contains[cd] %@", text)
            let ctx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            ctx.parent = CoreDataStack.shared.managedObjectContext
            let objects = try! ctx.fetch(req)
            DispatchQueue.main.async {
                let ids = objects.map { $0.objectID }
                self.updateTableViewWithResults(ids)
            }
        }
        searchQueue.addOperation(op)
    }

    fileprivate func updateTableViewWithResults(_ objectIds: [NSManagedObjectID]) {
        let ctx = CoreDataStack.shared.managedObjectContext
        searchResults = objectIds.flatMap {
            ctx.object(with: $0) as? Food
        }
        searchTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }

    fileprivate func showsCancelButton() {
        searchBar.snp.removeConstraints()
        searchBar.snp.makeConstraints {
            $0.left.equalTo(searchBarContainer).offset(15)
            $0.right.equalTo(searchCancelBtn.snp.left).offset(-10)
            $0.bottom.equalTo(searchBarContainer).offset(-10)
        }
        UIView.animate(withDuration: 0.35, animations: {
            self.searchBarContainer.layoutIfNeeded()
        }) 
    }

    fileprivate func hidesCancelButton() {
        searchBar.snp.removeConstraints()
        searchBar.snp.makeConstraints {
            $0.left.equalTo(searchBarContainer).offset(15)
            $0.right.equalTo(searchBarContainer).offset(-15)
            $0.bottom.equalTo(searchBarContainer).offset(-10)
        }
        UIView.animate(withDuration: 0.35, animations: {
            self.searchBarContainer.layoutIfNeeded()
        }) 
    }

    fileprivate func showsSearchTableView() {
        view.addSubview(searchTableView)
        searchTableView.snp.makeConstraints {
            $0.top.equalTo(searchBarContainer.snp.bottom)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.bottom.equalTo(view)
        }
        searchTableView.layoutIfNeeded()
        searchTableView.alpha = 0
        UIView.animate(withDuration: 0.35, animations: {
            self.searchTableView.alpha = 1
        }) 
    }

    fileprivate func hideTableView() {
        UIView.animate(withDuration: 0.35, animations: {
            self.searchTableView.alpha = 0
            }, completion: { finished in
                self.searchTableView.removeFromSuperview()
        })
    }

    func cancelBtnClicked(_ sender: UIButton) {
        if searchIsShown {
            searchBar.placeholder = "Rechercher un aliment"
            searchIsShown = false
            searchBar.resignFirstResponder()
            hidesCancelButton()
            hideTableView()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension CategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let cat = fetchedResultsController.object(at: indexPath) 
        let foodList = FoodListViewController()
        foodList.category = cat
        navigationController?.show(foodList, sender: nil)
        
        if let name = cat.name {
            Analytics.instance.trackViewCategory(name)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension CategoryViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        if type == NSFetchedResultsChangeType.insert {
            collectionViewAnimationBlocks.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertItems(at: [newIndexPath!])
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.update {
            collectionViewAnimationBlocks.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadItems(at: [indexPath!])
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.move {
            collectionViewAnimationBlocks.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.delete {
            collectionViewAnimationBlocks.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteItems(at: [indexPath!])
                    }
                    })
            )
        }
    }

    // In the did change section method:
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if type == NSFetchedResultsChangeType.insert {
            collectionViewAnimationBlocks.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertSections(IndexSet(integer: sectionIndex))
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.update {
            collectionViewAnimationBlocks.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadSections(IndexSet(integer: sectionIndex))
                    }
                    })
            )
        } else if type == NSFetchedResultsChangeType.delete {
            collectionViewAnimationBlocks.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteSections(IndexSet(integer: sectionIndex))
                    }
                    })
            )
        }
    }

    // And finally, in the did controller did change content method:
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView!.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.collectionViewAnimationBlocks {
                operation.start()
            }
            }, completion: { (finished) -> Void in
                self.collectionViewAnimationBlocks.removeAll(keepingCapacity: false)
        })
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FoodCell.reuseIdentifier, for: indexPath) as! FoodCell
        let food = searchResults[indexPath.row]
        cell.iconImageView.image = food.dangerImage
        cell.foodLbl.attributedText = attributedTextForSearchResult(food, searchText: searchingText)
        return cell
    }
    fileprivate func attributedTextForSearchResult(_ food: Food, searchText: String) -> NSAttributedString {
        let foodName = food.name ?? ""
        let attr = NSMutableAttributedString(string: foodName)

        attr.addAttribute(NSFontAttributeName,
                          value: UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium),
                          range: NSMakeRange(0, attr.length))

        attr.addAttribute(NSForegroundColorAttributeName,
                          value: UIColor.black.withAlphaComponent(0.4),
                          range: NSRange(0..<attr.length))

        let foodNameStr = NSString(string: foodName)
        let range = foodNameStr.range(of: searchText,
                                              options: [.diacriticInsensitive, .caseInsensitive],
                                              range: NSMakeRange(0, attr.length), locale: Locale.current)
        if range.location != NSNotFound {
            attr.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: range)
        }

        return attr
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        searchBar.resignFirstResponder()

        let food = searchResults[indexPath.row]
        let foodController = FoodDetailViewController()
        foodController.food = food
        navigationController?.show(foodController, sender: nil)
        
        if let name = food.name {
            Analytics.instance.trackViewFood(name, from: "search")
        }
    }
}
