//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 08.10.2024.
//

import Foundation
import UIKit

final class AlertPresenter {
    weak var alertDelegate: AlertPresenterDelegate?
    
    func showAlert(on viewController: UIViewController, with model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alert.addAction(action)
        alert.preferredAction = action
        viewController.present(alert, animated: true)
    }
}
