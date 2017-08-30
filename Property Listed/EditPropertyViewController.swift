//
//  EditPropertyViewController.swift
//  Property Listed
//
//  Created by Jeremy Tay on 29/08/2017.
//  Copyright © 2017 Jeremy Tay. All rights reserved.
//

import UIKit
import CoreData

protocol DeleteOwnerDelegate {
    func deleteOwner (at : Int)
}

class EditPropertyViewController: UIViewController {
    
    var propertyOwnerList : PropertyOwner?
    var index : Int?
    var delegate : DeleteOwnerDelegate?
    
    @IBOutlet weak var propertyNameTextField: UITextField!
    @IBOutlet weak var propertyPriceTextField: UITextField!
    @IBOutlet weak var propertyAreaTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let pOwners = propertyOwnerList else { return }
        
        propertyNameTextField.text = pOwners.propertyName
        propertyPriceTextField.text = "\(pOwners.propertyValue)"
        propertyAreaTextField.text = pOwners.propertyLocation
        
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        
        guard let deletingOwner = propertyOwnerList else { return }
        
        if let i = index {
            delegate?.deleteOwner(at: i)
        }
        
        DataController.moc.delete(deletingOwner)
        DataController.saveContext()
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let name = propertyNameTextField.text else { return }
        guard let valueText = propertyPriceTextField.text else { return }
        guard let area = propertyAreaTextField.text else { return }
        
        if name == "" || area == "" {
            emptyWarningPrompt()
        }
        
        guard let value = Int32(valueText) else {
            return print("Conversion failed")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func emptyWarningPrompt () {
        let errorPrompt = UIAlertController(title: "Warning", message: "Don't leave text field blank", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Understand", style: .default, handler: nil)
        errorPrompt.addAction(cancel)
        present(errorPrompt, animated: true, completion:  nil)
    }

}
