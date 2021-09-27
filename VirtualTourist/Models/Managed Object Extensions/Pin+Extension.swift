//
//  Pin+Extension.swift
//  VirtualTourist
//
//  Created by Han Hlaing Moe on 27/09/2021.
//

import Foundation
import CoreData
import MapKit

extension Pin: MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
