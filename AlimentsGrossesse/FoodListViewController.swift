//
//  FoodListViewController.swift
//  AlimentsGrossesse
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

        tableView = UITableView(frame: .zero, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        view.addSubview(tableView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = category?.name
        view.backgroundColor = UIColor.whiteColor()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        configureFetchedResultsController()

        let backIcon = UIBarButtonItem(image: UIImage(named: "back_icon"), style: .Plain, target: self, action: #selector(FoodListViewController.backBtnClicked(_:)))
        navigationItem.leftBarButtonItem = backIcon

        tableView.rowHeight = 34
        tableView.registerClass(FoodCell.self, forCellReuseIdentifier: FoodCell.reuseIdentifier)
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.tableFooterView = UIView()
        configureLayoutConstraints()
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
        fetchedResultsController = NSFetchedResultsController(fetchRequest: req, managedObjectContext: CoreDataStack.shared.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        do {
            try fetchedResultsController.performFetch()
        } catch let err as NSError {
            print("Error while fetching foods: \(err)")
        }
    }

    private func configureLayoutConstraints() {
        tableView.snp_makeConstraints {
            $0.edges.equalTo(view)
        }
    }
}

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
        cell.foodLbl.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
        cell.foodLbl.text = food.name
        return cell
    }
}

extension FoodListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let food = fetchedResultsController.objectAtIndexPath(indexPath) as! Food
        let detail = FoodDetailViewController()
        detail.food = food
        navigationController?.pushViewController(detail, animated: true)
    }
}
