//
//  FavListViewController.swift
//  Foodancy
//
//  Created by David Miotti on 26/08/16.
//  Copyright © 2016 David Miotti. All rights reserved.
//

import UIKit
import SwiftHelpers
import CoreData

final class FavListViewController: UIViewController {

    private var favTableView: UITableView!

    private var fetchedResultsController: NSFetchedResultsController!

    private var emptyView: FavEmptyView!

    override func loadView() {
        super.loadView()

        favTableView = UITableView(frame: .zero, style: .Plain)
        favTableView.separatorStyle = .None
        favTableView.rowHeight = 44
        favTableView.registerClass(FoodCell.self, forCellReuseIdentifier: FoodCell.reuseIdentifier)
        favTableView.backgroundColor = UIColor.whiteColor()
        favTableView.tableFooterView = UIView()
        view.addSubview(favTableView)

        emptyView = FavEmptyView()
        emptyView.alpha = 0
        view.addSubview(emptyView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L("Mes favoris")

        prepareFechedResultsController()

        favTableView.delegate = self
        favTableView.dataSource = self

        configureLayoutConstraints()
    }

    private func prepareFechedResultsController() {
        let req = Food.entityFetchRequest()
        req.predicate = NSPredicate(format: "favDate != nil")
        req.sortDescriptors = [ NSSortDescriptor(key: "favDate", ascending: false) ]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: req, managedObjectContext: CoreDataStack.shared.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()

            favTableView.reloadData()

            showEmptyViewIfNeeded()
        } catch let err as NSError {
            print("Error while fetching faved: \(err)")
        }
    }

    private func showEmptyViewIfNeeded() {
        UIView.animateWithDuration(0.35) {
            if self.fetchedResultsController == nil || self.fetchedResultsController.fetchedObjects?.count == 0 {
                self.emptyView.alpha = 1
            } else {
                self.emptyView.alpha = 0
            }
        }
    }

    private func configureLayoutConstraints() {
        favTableView.snp_makeConstraints {
            $0.edges.equalTo(view)
        }

        emptyView.snp_makeConstraints {
            $0.edges.equalTo(view)
        }
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
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    private func configureCell(cell: FoodCell, atIndexPath indexPath: NSIndexPath) {
        let food = fetchedResultsController.objectAtIndexPath(indexPath) as! Food
        cell.foodLbl.text = food.name
        cell.iconImageView.image = food.dangerImage
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let food = fetchedResultsController.objectAtIndexPath(indexPath) as! Food
        food.favDate = nil
        do {
            try food.managedObjectContext?.save()
        } catch let err as NSError {
            print("Error while saving context: \(err)")
        }
    }
}

// MARK: - UITableViewDelegate
extension FavListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let foodController = FoodDetailViewController()
        foodController.food = fetchedResultsController.objectAtIndexPath(indexPath) as? Food
        navigationController?.showViewController(foodController, sender: nil)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension FavListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        favTableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                favTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break
        case .Delete:
            if let indexPath = indexPath {
                favTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break
        case .Update:
            if let indexPath = indexPath {
                let cell = favTableView.cellForRowAtIndexPath(indexPath) as! FoodCell
                configureCell(cell, atIndexPath: indexPath)
            }
            break
        case .Move:
            if let indexPath = indexPath {
                favTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }

            if let newIndexPath = newIndexPath {
                favTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            break
        case .Delete:
            break
        default:
            break
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        favTableView.endUpdates()
        showEmptyViewIfNeeded()
    }
}
