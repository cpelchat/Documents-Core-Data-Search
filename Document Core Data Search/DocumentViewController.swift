//
//  DocumentViewController.swift
//  Documents Core Data
//
//  Created by Cassidy Pelchat on 10/7/19.
//  Copyright © 2019 Cassidy Pelchat. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    var document: Document?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""

        if let document = document {
            let name = document.name
            nameTextField.text = name
            contentTextView.text = document.content
            title = name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func save(_ sender: Any) {
        guard let name = nameTextField.text else {
            alertNotifyUser(message: "Document not saved.\nThe name is not accessible.")
            return
        }
        
        let documentName = name.trimmingCharacters(in: .whitespaces)
        if (documentName == "") {
            alertNotifyUser(message: "Document not saved.\nA name is required.")
            return
        }
        
        let content = contentTextView.text
        
        if document == nil {

            document = Document(name: documentName, content: content)
        } else {

            document?.update(name: documentName, content: content)
        }
        
        if let document = document {
            do {
                let managedContext = document.managedObjectContext
                try managedContext?.save()
            } catch {
                alertNotifyUser(message: "The document context could not be saved.")
            }
        } else {
            alertNotifyUser(message: "The document could not be created.")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        title = nameTextField.text
    }
}
