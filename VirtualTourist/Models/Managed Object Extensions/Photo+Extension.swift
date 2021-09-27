//
//  Photo+Extension.swift
//  VirtualTourist
//
//  Created by Han Hlaing Moe on 27/09/2021.
//

import Foundation

extension Photo {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
