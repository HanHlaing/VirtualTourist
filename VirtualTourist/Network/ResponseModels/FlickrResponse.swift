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

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [PhotoStruct]
}

struct PhotoStruct: Codable {
    let id: String
    let server: String
    let farm: Int
    let secret: String
}
