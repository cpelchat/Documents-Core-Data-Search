//
//  DocumentsViewController.swift
//  Documents Core Data
//
//  Created by Cassidy Pelchat on 10/7/19.
//  Copyright © 2019 Cassidy Pelchat. All rights reserved.
//

import UIKit
import CoreData

class DocumentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating{

    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var documentsTableView: UITableView!
    
    let dateFormatter = DateFormatter()
    var documents = [Document]()
    var filteredDocuments = [Document]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Documents"

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        fetchDocuments()
        documentsTableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredDocuments = documents.filter({( document : Document) -> Bool in
            return (document.name?.lowercased().contains(searchText.lowercased()))!
        })
        
        documentsTableView.reloadData()
    }

    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) {
            (alertAction) -> Void in
            print("OK selected")
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchDocuments() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            documents = try managedContext.fetch(fetchRequest)
        } catch {
            alertNotifyUser(message: "Fetch for documents could not be performed.")
            return
        }
    }
    
    func deleteDocument(at indexPath: IndexPath) {
        let document = documents[indexPath.row]
        
        if let managedObjectContext = document.managedObjectContext {
            managedObjectContext.delete(document)
            
            do {
                try managedObjectContext.save()
                self.documents.remove(at: indexPath.row)
                documentsTableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                alertNotifyUser(message: "Delete failed.")
                documentsTableView.reloadData()
            }
        }
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredDocuments.count
        }
        
        return documents.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath)
        
        if let cell = cell as? DocumentTableViewCell {
            let document = documents[indexPath.row]
            cell.nameLabel.text = document.name
            cell.sizeLabel.text = String(document.size) + " bytes"
            
            if let modifiedDate = document.modifiedDate {
                cell.modifiedLabel.text = dateFormatter.string(from: modifiedDate)
            } else {
                cell.modifiedLabel.text = "unknown"
            }
        }
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DocumentViewController,
           let segueIdentifier = segue.identifier, segueIdentifier == "existingDocument",
           let row = documentsTableView.indexPathForSelectedRow?.row {
                destination.document = documents[row]
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteDocument(at: indexPath)
        }
    }
}
