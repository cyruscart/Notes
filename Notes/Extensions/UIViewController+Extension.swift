//
//  UIViewController+Extension.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, completion: @escaping (() -> Void)) {
        let alert = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(
            title: "Удалить",
            style: .destructive) { _ in
                completion()
            }
        
        let cancelAction = UIAlertAction(
            title: "Отмена",
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
