//
//  Utils.swift
//  AsynAwait
//
//  Created by trungnghia on 11/03/2023.
//

import UIKit

class Utils {
    
    static let shared = Utils()
    private init() {}
    
    func showAlert(viewController: UIViewController, message: String) {
        let alert = UIAlertController(title: "Opps!", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        viewController.present(alert, animated: true)
    }
}
