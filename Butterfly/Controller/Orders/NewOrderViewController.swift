//
//  NewOrderViewController.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//

import UIKit
import SkyFloatingLabelTextField

protocol NewOrderControllerDelegate: class {
    func newOrderControllerDidFinish(canceled: Bool)
}

class NewOrderViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var orderNumberTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var deliveryNoteTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var isActiveLabel: UILabel!
    @IBOutlet private weak var isActiveSwitch: UISwitch!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    
    // MARK: - Private
    
    private let requiredErrorMsg = NSLocalizedString("formValidation.required", comment: "")
    private let onlyDigitsErrorMsg = NSLocalizedString("formValidation.onlyDigits", comment: "")
    private let orderNumberExistsErrorMsg = NSLocalizedString("formValidation.orderNumberExists", comment: "")
    
    
    // MARK: - Prperties
    
    weak var delegate: NewOrderControllerDelegate?
    
    private var context = CoreDataManager.shared.managedContext
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initial setup
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // focus the order number field
        orderNumberTextField.becomeFirstResponder()
    }
    
    // MARK: - UI
    
    private func configureView() {
        // title
        titleLabel.text = NSLocalizedString("orders.add.title", comment: "")
        // order number
        orderNumberTextField.title = NSLocalizedString("orders.add.orderNumber", comment: "")
        orderNumberTextField.placeholder = NSLocalizedString("orders.add.orderNumberPlaceholder", comment: "")
        orderNumberTextField.titleFormatter = { $0 }
        orderNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        orderNumberTextField.delegate = self
        // delivery note
        deliveryNoteTextField.title = NSLocalizedString("orders.add.deliveryNote", comment: "")
        deliveryNoteTextField.placeholder = NSLocalizedString("orders.add.deliveryNotePlaceholder", comment: "")
        deliveryNoteTextField.titleFormatter = { $0 }
        deliveryNoteTextField.delegate = self
        // is active
        isActiveLabel.text = NSLocalizedString("orders.add.isActive", comment: "")
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
        if let order = context.insert(entityClass: Order.self) {
            let now = Date()
            order.id = Order.newOrderID(in: context)
            order.orderNumber = orderNumberTextField.text!
            order.active = isActiveSwitch.isOn
            order.issueDate = now
            order.lastUpdated = now
            context.saveContext()
        }
        
        // notify the delegate & dismiss
        delegate?.newOrderControllerDidFinish(canceled: false)
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func cancelButtonTapped(_ sender: UIButton) {
        delegate?.newOrderControllerDidFinish(canceled: true)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Textfield
    
    @objc
    private func textFieldDidChange(_ sender: UITextField) {
        if sender == orderNumberTextField {
            validateOrderNumber()
        }
    }
    
    // MARK: - Helpers
    
    private func formIsValid() -> Bool {
        return validateOrderNumber(checkForUnicity: true)
    }
    
    @discardableResult
    private func validateOrderNumber(checkForUnicity: Bool = false) -> Bool {
        let orderNumber = (orderNumberTextField.text ?? "").trimmed()
        let onlyDigits = isOnlyDigits(orderNumber)
        orderNumberTextField.errorMessage = onlyDigits ? nil : onlyDigitsErrorMsg
        let empty = orderNumber.isEmpty
        orderNumberTextField.errorMessage = empty ? requiredErrorMsg : orderNumberTextField.errorMessage
        var orderNumberTaken = false
        if checkForUnicity {
            orderNumberTaken = Order.orderExists(orderNumber, in: context)
            orderNumberTextField.errorMessage = orderNumberTaken ? orderNumberExistsErrorMsg : orderNumberTextField.errorMessage
        }
        
        return !empty && onlyDigits && !orderNumberTaken
    }
    
    private func isOnlyDigits(_ aString: String) -> Bool {
        return aString.unicodeScalars.allSatisfy { "0"..."9" ~= $0 }
    }
}

// MARK: - Text field delegate

extension NewOrderViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == orderNumberTextField {
            deliveryNoteTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
