//
//  FoodListViewController.swift
//  Foodancy
//
//  Created by David Miotti on 26/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import CoreData
import SwiftHelpers

final class FoodListViewController: UIViewController {

    var category: FoodCategory?

    private var tableView: UITableView!

    private var fetchedResultsController: NSFetchedResultsController!

    override func loadView() {
        super.loadView()

        view.backgroundColor = UIColor.whiteColor()

        tableView = UITableView(frame: .zero, style: .Plain)
        tableView.tintColor = UIColor.appTintColor()
        tableView.separatorStyle = .None
        tableView.rowHeight = 44
        tableView.registerClass(FoodCell.self, forCellReuseIdentifier: FoodCell.reuseIdentifier)
        tableView.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)

        let backIcon = UIBarButtonItem(image: UIImage(named: "back_icon"), style: .Plain, target: self, action: #selector(FoodListViewController.backBtnClicked(_:)))
        navigationItem.leftBarButtonItem = backIcon
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false

        title = category?.name

        tableView.tableFooterView = UIView()

        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        configureFetchedResultsController()

        configureLayoutConstraints()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func backBtnClicked(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }

    private func configureFetchedResultsController() {
        let req = Food.entityFetchRequest()
        if let category = category {
            req.predicate = NSPredicate(format: "foodCategory == %@", category)
        }
        req.sortDescriptors = [ NSSortDescriptor(key: "name", ascending: true) ]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: req, managedObjectContext: CoreDataStack.shared.managedObjectContext, sectionNameKeyPath: "name", cacheName: nil)

        do {
            try fetchedResultsController.performFetch()
        } catch let err as NSError {
            print("Error while fetching foods: \(err)")
        }
    }

    private func configureLayoutConstraints() {
        tableView.snp_makeConstraints {
            $0.edges.equalTo(view).offset(UIEdgeInsets(top: 64, left: 0, bottom: -50, right: 0))
        }
    }
}

// MARK: - UITableViewDataSource
extension FoodListViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(FoodCell.reuseIdentifier, forIndexPath: indexPath) as! FoodCell
        let food = fetchedResultsController.objectAtIndexPath(indexPath) as! Food
        cell.iconImageView.image = food.dangerImage
        cell.foodLbl.text = food.name
        return cell
    }

    private var sectionTitles: [String] {
        let titles = fetchedResultsController.sectionIndexTitles
        var newTitles = [String]()
        for (index, title) in titles.enumerate() {
            newTitles.append(title)
            if index < titles.count - 1 {
                newTitles.append("")
            }
        }
        return newTitles
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return sectionTitles
    }
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        var newIndex = index
        var newTitle = title
        if index % 2 != 0 {
            newIndex = index - 1
        }
        newTitle = sectionTitles[newIndex]
        return fetchedResultsController.sectionForSectionIndexTitle(newTitle, atIndex: newIndex / 2)
    }
}

// MARK: - UITableViewDelegate
extension FoodListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let food = fetchedResultsController.objectAtIndexPath(indexPath) as! Food
        let detail = FoodDetailViewController()
        detail.food = food
        navigationController?.pushViewController(detail, animated: true)
    }
}
