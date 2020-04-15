//
//  ViewController.swift
//  StamuraiAssignment
//
//  Created by Rahul Bawane on 14/04/20.
//  Copyright © 2020 Rahul Bawane. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var minTextField: UITextField!
    @IBOutlet weak var maxTextField: UITextField!
    
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        minTextField.delegate = self
        minTextField.keyboardType = .numberPad
        maxTextField.delegate = self
        maxTextField.keyboardType = .numberPad
        ratingButton.setTitle("Set range", for: .normal)
    }

    @IBAction func ratingAction(_ sender: UIButton) {
        minTextField.resignFirstResponder()
        maxTextField.resignFirstResponder()
        let min = Int(minTextField.text!) ?? 0
        let max = Int(maxTextField.text!) ?? 9
        if min < max {
            let vc = self.storyboard?.instantiateViewController(identifier: "EnterRatingVC") as! EnterRatingVC
            vc.minimum = min
            vc.maximum = max
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func historyActionn(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "RatingHistoryVC") as! RatingHistoryVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.count == 1 && string != "" {
            return false
        }
        if textField == minTextField {
            ratingButton.setTitle("Range \(string) - \(maxTextField.text!)", for: .normal)
        } else {
            ratingButton.setTitle("Range \(minTextField.text!) - \(string)", for: .normal)
        }
        return true
    }
}

