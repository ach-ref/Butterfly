//
//  NewItemViewController.swift
//  Butterfly
//
//  Created by Achref Marzouki on 25/02/2021.
//

import UIKit
import SkyFloatingLabelTextField

protocol NewItemControllerDelegate: class {
    func newItemControllerDidFinish(canceled: Bool)
}

class NewItemViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var productIDTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var quantityTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var isActiveLabel: UILabel!
    @IBOutlet private weak var isActiveSwitch: UISwitch!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    
    // MARK: - Private
    
    private let requiredErrorMsg = NSLocalizedString("formValidation.required", comment: "")
    private let onlyDigitsErrorMsg = NSLocalizedString("formValidation.onlyDigits", comment: "")
    private let greaterThanZeroErrorMsg = NSLocalizedString("formValidation.greaterThanZero", comment: "")
    
    
    // MARK: - Prperties
    
    var order: Order!
    weak var delegate: NewItemControllerDelegate?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initial setup
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // focus the order number field
        productIDTextField.becomeFirstResponder()
    }
    
    // MARK: - UI
    
    private func configureView() {
        // title
        titleLabel.text = NSLocalizedString("orderDetail.addItem.title", comment: "")
        // order number
        productIDTextField.title = NSLocalizedString("orderDetail.addItem.productID", comment: "")
        productIDTextField.placeholder = NSLocalizedString("orderDetail.addItem.productIDPlaceholder", comment: "")
        productIDTextField.titleFormatter = { $0 }
        productIDTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        productIDTextField.delegate = self
        // delivery note
        quantityTextField.title = NSLocalizedString("orderDetail.addItem.quantity", comment: "")
        quantityTextField.placeholder = NSLocalizedString("orderDetail.addItem.quantityPlaceholder", comment: "")
        quantityTextField.titleFormatter = { $0 }
        quantityTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        quantityTextField.delegate = self
        // is active
        isActiveLabel.text = NSLocalizedString("orderDetail.addItem.isActive", comment: "")
        isActiveSwitch.isOn = false
        // cancel button
        cancelButton.setTitle(NSLocalizedString("general.cancel", comment: ""), for: .normal)
        cancelButton.tintColor = UIColor(named: "Primary")
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        // done button
        doneButton.setTitle(NSLocalizedString("general.done", comment: ""), for: .normal)
        doneButton.tintColor = UIColor(named: "Primary")
        doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc
    private func doneButtonTapped(_ sender: UIButton) {
        
        guard formIsValid() else {
            doneButton.shake()
            return
        }
        
        // end all editing
        view.endEditing(false)
        
        // add the order
        let context = order.managedObjectContext ?? CoreDataManager.shared.managedContext
        if let item = context.insert(entityClass: Item.self) {
            item.id = Item.newItemID(in: context)
            item.productItemId = Int32(productIDTextField.text!) ?? 0
            item.quantity = Int32(quantityTextField.text!) ?? 0
            item.active = isActiveSwitch.isOn
            item.lastUpdated = Date()
            item.order = order
            context.saveContext()
        }
        
        // notify the delegate & dismiss
        delegate?.newItemControllerDidFinish(canceled: false)
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func cancelButtonTapped(_ sender: UIButton) {
        delegate?.newItemControllerDidFinish(canceled: true)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Textfield
    
    @objc
    private func textFieldDidChange(_ sender: UITextField) {
        if sender == productIDTextField {
            validateProductID()
        } else if sender == quantityTextField {
            validateQuantity()
        }
    }
    
    // MARK: - Helpers
    
    private func formIsValid() -> Bool {
        let productIDIsValid = validateProductID()
        let quantityIsValid = validateQuantity()
        return productIDIsValid && quantityIsValid
    }
    
    @discardableResult
    private func validateProductID() -> Bool {
        let productID = (productIDTextField.text ?? "").trimmed()
        let onlyDigits = isOnlyDigits(productID)
        productIDTextField.errorMessage = onlyDigits ? nil : onlyDigitsErrorMsg
        let empty = productID.isEmpty
        productIDTextField.errorMessage = empty ? requiredErrorMsg : productIDTextField.errorMessage
        return !empty && onlyDigits
    }
    
    @discardableResult
    private func validateQuantity() -> Bool {
        let quantity = (quantityTextField.text ?? "").trimmed()
        let greaterThanZero = Int(quantity) ?? 0 > 0
        quantityTextField.errorMessage = greaterThanZero ? nil : greaterThanZeroErrorMsg
        let onlyDigits = isOnlyDigits(quantity)
        quantityTextField.errorMessage = onlyDigits ? quantityTextField.errorMessage : onlyDigitsErrorMsg
        let empty = quantity.isEmpty
        quantityTextField.errorMessage = empty ? requiredErrorMsg : quantityTextField.errorMessage
        return !empty && onlyDigits
    }
    
    private func isOnlyDigits(_ aString: String) -> Bool {
        return aString.unicodeScalars.allSatisfy { "0"..."9" ~= $0 }
    }
}

// MARK: - Text field delegate

extension NewItemViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == productIDTextField {
            quantityTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
