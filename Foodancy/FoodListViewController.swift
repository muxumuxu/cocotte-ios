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
    
    fileprivate var filterView: FilterView!
    fileprivate var tableView: UITableView!

    fileprivate var fetchedResultsController: NSFetchedResultsController<Food>!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = category?.name

        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        view.backgroundColor = UIColor.white
        
        filterView = FilterView()
        filterView.delegate = self
        filterView.items = [
            FilterItem(text: "Tous", selectedText: nil),
            FilterItem(image: #imageLiteral(resourceName: "filter_unselected_authorized"), selectedImage: #imageLiteral(resourceName: "good_icon")),
            FilterItem(image: #imageLiteral(resourceName: "filter_unselected_warning_icon"), selectedImage: #imageLiteral(resourceName: "warning_icon")),
            FilterItem(image: #imageLiteral(resourceName: "filter_unselected_forbidden_icon"), selectedImage: #imageLiteral(resourceName: "forbidden_icon"))
        ]
        view.addSubview(filterView)
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.tintColor = UIColor.appTintColor()
        tableView.separatorStyle = .none
        tableView.rowHeight = 44
        tableView.register(FoodCell.self, forCellReuseIdentifier: FoodCell.reuseIdentifier)
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        
        let backIcon = UIBarButtonItem(image: UIImage(named: "back_icon"), style: .plain, target: self, action: #selector(FoodListViewController.backBtnClicked(_:)))
        navigationItem.leftBarButtonItem = backIcon

        configureFetchedResultsController()

        configureLayoutConstraints()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func backBtnClicked(_ sender: UIButton) {
        let _ = navigationController?.popViewController(animated: true)
    }

    fileprivate func configureFetchedResultsController() {
        let req = NSFetchRequest<Food>(entityName: Food.entityName)
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

    fileprivate func configureLayoutConstraints() {
        filterView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(60)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(filterView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource
extension FoodListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FoodCell.reuseIdentifier, for: indexPath) as! FoodCell
        let food = fetchedResultsController.object(at: indexPath)
        cell.iconImageView.image = food.dangerImage
        cell.foodLbl.text = food.name
        return cell
    }

    fileprivate var sectionTitles: [String] {
        let titles = fetchedResultsController.sectionIndexTitles
        var newTitles = [String]()
        for (index, title) in titles.enumerated() {
            newTitles.append(title)
            if index < titles.count - 1 {
                newTitles.append("")
            }
        }
        return newTitles
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var newIndex = index
        var newTitle = title
        if index % 2 != 0 {
            newIndex = index - 1
        }
        newTitle = sectionTitles[newIndex]
        return fetchedResultsController.section(forSectionIndexTitle: newTitle, at: newIndex / 2)
    }
}

// MARK: - UITableViewDelegate
extension FoodListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let food = fetchedResultsController.object(at: indexPath) 
        let detail = FoodDetailViewController()
        detail.food = food
        navigationController?.show(detail, sender: nil)
        
        if let name = food.name {
            Analytics.instance.trackViewFood(name, from: "category")
        }
    }
}

// MARK: - FilterViewDelegate
extension FoodListViewController: FilterViewDelegate {
    func filter(view: FilterView, didSelectAt index: Int) {
        print("Did select filter at: \(index)")
    }
}
