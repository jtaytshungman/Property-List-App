//
//  PropertyOwnersViewController.swift
//  Property Listed
//
//  Created by Jeremy Tay on 29/08/2017.
//  Copyright © 2017 Jeremy Tay. All rights reserved.
//

import UIKit
import CoreData



class PropertyOwnersViewController: UIViewController {
    
    var propertyOwners : [PropertyOwner] = []
    var fetchRC : NSFetchedResultsController <PropertyOwner>!
    
    @IBOutlet weak var tableView: UITableView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.reloadData()
        
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        addNewPropertyOwner()
    }
    

    func loadData() {
        let request = NSFetchRequest<PropertyOwner>(entityName: "PropertyOwner")
        let sort = NSSortDescriptor(key: "propertyOwnerName", ascending: true)
        request.sortDescriptors = [sort]
        
        fetchRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: DataController.moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchRC.delegate = self
        
        do {
            try fetchRC.performFetch()
            tableView.reloadData()
        }
        catch {
            
        }
    }
    
    func addNewPropertyOwner() {
        
        let addNewPropertyOwner = UIAlertController(title: "New Owner", message: "Add new property owner", preferredStyle: .alert)
        
        addNewPropertyOwner.addTextField { (propertyOwnerName) in
            propertyOwnerName.placeholder = "Owner's Name"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            guard let owner = addNewPropertyOwner.textFields?[0], let newPropertyOwnerName = owner.text else {
                return
            }
            
            if newPropertyOwnerName.replacingOccurrences(of: " ", with: "") == "" {
                return self.emptyWarningPrompt()
            }
            
            guard let desc = NSEntityDescription.entity(forEntityName: "PropertyOwner", in: DataController.moc) else { return }
            let newOwner = PropertyOwner(entity: desc, insertInto: DataController.moc)
            
            newOwner.propertyOwnerName = newPropertyOwnerName
            
            DataController.saveContext()
        }
        
        addNewPropertyOwner.addAction(cancel)
        addNewPropertyOwner.addAction(add)
        
        present (addNewPropertyOwner, animated: true, completion: nil)
        
    }
    
    func emptyWarningPrompt () {
        let errorPrompt = UIAlertController(title: "Warning", message: "Don't leave text field blank", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Understand", style: .default, handler: nil)
        errorPrompt.addAction(cancel)
        present(errorPrompt, animated: true, completion:  nil)
    }
    
}
extension PropertyOwnersViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchRC.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let homeOwner = fetchRC.fetchedObjects?[indexPath.row]
        
        cell.textLabel?.text = homeOwner?.propertyOwnerName
        cell.detailTextLabel?.text = "\(homeOwner?.propertyLocation) : \(homeOwner?.propertyValue)"
        
        return cell
    }
    
}

extension PropertyOwnersViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ownerSelected = fetchRC.fetchedObjects?[indexPath.row]
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let editPropertyVC = mainStoryBoard.instantiateViewController(withIdentifier: "EditPropertyViewController") as? EditPropertyViewController else { return }
        
        editPropertyVC.delegate = self
        editPropertyVC.index = indexPath.row
        editPropertyVC.propertyOwnerList = ownerSelected
    
        navigationController?.pushViewController(editPropertyVC, animated: true)
        
    }
    
}

extension PropertyOwnersViewController : DeleteOwnerDelegate {
    func deleteOwner(at index : Int) {
        fetchRC.object(at:)
    }
}

extension PropertyOwnersViewController : NSFetchedResultsControllerDelegate {
    open override func willChangeValue(forKey key: String) {
        tableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("insert")
            guard let ip = newIndexPath else {
                return
            }
            tableView.insertRows(at: [ip], with: .right)
        case .update:
            print("update")
            guard let ip = newIndexPath else {
                return
            }
            tableView.reloadRows(at: [ip], with: .bottom)
        case .move:
            print("move")
            guard let oldIndex = indexPath,
                let newIndex = newIndexPath
                else { return }
            tableView.moveRow(at: oldIndex, to: newIndex)
        case .delete:
            print("delete")
            guard let ip = indexPath else {
                return
            }
            tableView.deleteRows(at: [ip], with: .fade)
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
