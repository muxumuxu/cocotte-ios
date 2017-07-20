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

    fileprivate var favTableView: UITableView!

    fileprivate var fetchedResultsController: NSFetchedResultsController<Food>!

    fileprivate var emptyView: FavEmptyView!

    override func loadView() {
        super.loadView()

        favTableView = UITableView(frame: .zero, style: .plain)
        favTableView.separatorStyle = .none
        favTableView.rowHeight = 44
        favTableView.register(FoodCell.self, forCellReuseIdentifier: FoodCell.reuseIdentifier)
        favTableView.backgroundColor = UIColor.white
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

    fileprivate func prepareFechedResultsController() {
        let req = NSFetchRequest<Food>(entityName: Food.entityName)
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

    fileprivate func showEmptyViewIfNeeded() {
        UIView.animate(withDuration: 0.35, animations: {
            if self.fetchedResultsController == nil || self.fetchedResultsController.fetchedObjects?.count == 0 {
                self.emptyView.alpha = 1
            } else {
                self.emptyView.alpha = 0
            }
        }) 
    }

    fileprivate func configureLayoutConstraints() {
        favTableView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }

        emptyView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }
}

// MARK: - UITableViewDataSource
extension FavListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FoodCell.reuseIdentifier, for: indexPath) as! FoodCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    fileprivate func configureCell(_ cell: FoodCell, atIndexPath indexPath: IndexPath) {
        let food = fetchedResultsController.object(at: indexPath) 
        cell.foodLbl.text = food.name
        cell.iconImageView.image = food.dangerImage
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let food = fetchedResultsController.object(at: indexPath)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let foodController = FoodDetailViewController()
        foodController.food = fetchedResultsController.object(at: indexPath)
        navigationController?.show(foodController, sender: nil)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension FavListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favTableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                favTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .delete:
            if let indexPath = indexPath {
                favTableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case .update:
            if let indexPath = indexPath {
                let cell = favTableView.cellForRow(at: indexPath) as! FoodCell
                configureCell(cell, atIndexPath: indexPath)
            }
            break
        case .move:
            if let indexPath = indexPath {
                favTableView.deleteRows(at: [indexPath], with: .fade)
            }

            if let newIndexPath = newIndexPath {
                favTableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            break
        case .delete:
            break
        default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favTableView.endUpdates()
        showEmptyViewIfNeeded()
    }
}
