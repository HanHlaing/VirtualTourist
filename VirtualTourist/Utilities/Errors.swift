//
//  Errors.swift
//  VirtualTourist
//
//  Created by Han Hlaing Moe on 02/10/2021.
//

import Foundation
import UIKit

// List of errors that could happen during running the app
public enum Errors: Error {
    case flickrServer
    case photoDownload
}

// Description of each
extension Errors: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .flickrServer: return "Error from the server, please check your connection & try again."
        case .photoDownload: return "Error downloading"
        }
    }
}

// Commom alert for errors
func showError(message: String, actualVC: UIViewController) {
    let alertVC = UIAlertController(title: "An Error Has Occurred", message: message, preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    actualVC.present(alertVC, animated: true, completion: nil)
}
