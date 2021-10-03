//
//  ImageCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Han Hlaing Moe on 29/09/2021.
//

import Foundation
import UIKit

class ImageViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!{
        didSet{
            imageView.image = UIImage(named: "noImagePlaceholder")
        }
    }
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    public func showActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }

    public func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
}
