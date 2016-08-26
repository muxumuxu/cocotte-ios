//
//  FavListViewController.swift
//  AlimentsGrossesse
//
//  Created by David Miotti on 26/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers
import CoreData

final class FavListViewController: SHKeyboardViewController {

    private let searchQueue = NSOperationQueue()
    private var searchResults = [Food]()
    private var searchBarContainer: UIView!
    private var searchCancelBtn: UIButton!
    private var searchBar: UISearchBar!
    private var searchTableView: UITableView!
    private var searchIsShown = false
    private var searchingText = ""

    private var favTableView: UITableView!

    private var fetchedResultsController: NSFetchedResultsController!

    override func loadView() {
        super.loadView()

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
        searchBar.delegate = self
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

        favTableView = UITableView(frame: .zero, style: .Plain)
        favTableView.separatorStyle = .None
        favTableView.rowHeight = 44
        favTableView.registerClass(FoodCell.self, forCellReuseIdentifier: FoodCell.reuseIdentifier)
        favTableView.backgroundColor = UIColor.whiteColor()
        favTableView.tableFooterView = UIView()
        view.addSubview(favTableView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None

        definesPresentationContext = true

        prepareFechedResultsController()

        registerKeyboardNotificationsForScrollableView(searchTableView)

        favTableView.delegate = self
        favTableView.dataSource = self

        configureLayoutConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func prepareFechedResultsController() {
        let req = Food.entityFetchRequest()
        req.predicate = NSPredicate(format: "favDate != nil")
        req.sortDescriptors = [ NSSortDescriptor(key: "favDate", ascending: false) ]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: req, managedObjectContext: CoreDataStack.shared.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        do {
            try fetchedResultsController.performFetch()
            favTableView.reloadData()
        } catch let err as NSError {
            print("Error while fetching faved: \(err)")
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
            $0.right.equalTo(searchBarContainer).offset(-14)
            $0.centerY.equalTo(searchBar)
        }

        favTableView.snp_makeConstraints {
            $0.top.equalTo(searchBarContainer.snp_bottom)
            $0.left.equalTo(view)
            $0.right.equalTo(view)
            $0.bottom.equalTo(view)
        }
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

// MARK: - UITableViewDataSource
extension FavListViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(FoodCell.reuseIdentifier, forIndexPath: indexPath) as! FoodCell
        let food = fetchedResultsController.objectAtIndexPath(indexPath) as! Food
        cell.foodLbl.text = food.name
        cell.iconImageView.image = food.dangerImage
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FavListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension FavListViewController: UISearchBarDelegate {
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
        searchBar.snp_remakeConstraints {
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
