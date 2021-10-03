//
//  FlickrResponse.swift
//  VirtualTourist
//
//  Created by Han Hlaing Moe on 02/10/2021.
//

import Foundation

struct FlickrResponse: Codable {
    let photos: Photos
    let stat: String
}
