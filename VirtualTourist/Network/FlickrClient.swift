//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Han Hlaing Moe on 29/09/2021.
//

import Foundation
import CoreData

class FlickrClient {
    
    static let apiKey = "1858343253849e0404c0596bd506f628"
    static let secretKey = "3aa2c3043c67c8e8"
    
    enum Endpoints {
        
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        
        case getPhotos(Double, Double, Int)
        
        var stringValue: String {
            switch self {
           
            case .getPhotos(let lat, let lon, let pageNum):
                return Endpoints.base
                + "&api_key=\(FlickrClient.apiKey)"
                + "&lat=\(lat)"
                + "&lon=\(lon)"
                + "&radius=15"
                + "&per_page=20"
                + "&page=\(pageNum)"
                + "&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // Random number to use in Flickr Request
    class func randomPhotos() -> Int {
        let n = Int.random(in: 1...10)
        return n
    }
    
    // This function does a request to get photos by location from Flickr
    class func getPhotosByLocation(lat: Double, lon: Double, completion: @escaping (FlickrResponse?, Error?) -> Void) {
        let url = Endpoints.getPhotos(lat, lon, randomPhotos()).url
        taskForGETRequest(url: url, responseType: FlickrResponse.self) { response, error in
            guard let response = response else {
                completion(nil, error)
                return
            }
            completion(response, nil)
        }
    }
    
    // Get an image path from Flickr's response
    class func getImgPath(photoStruct: PhotoStruct) -> String {
        let imagePath: String = "https://farm\(photoStruct.farm).staticflickr.com/\(photoStruct.server)/\(photoStruct.id)_\(photoStruct.secret).jpg"
        
        return imagePath
    }
    
    class func downloadImage(imgUrl: URL, completion: @escaping (Data?, Error?) -> Void) {
         DispatchQueue.global(qos: .background).async {
            let request = URLRequest(url: imgUrl)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                completion(data, nil)
            }
            task.resume()
        }
    }
    
    class func savePhotoURL(imgPath: String, context: NSManagedObjectContext) -> Photo {
        let url = URL(string: imgPath)
        let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as! Photo
        photo.imageUrl = url
        return photo
    }
}
    
    // MARK: - Network methods
    @discardableResult func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let requestObject = try decoder.decode(responseType.self, from: data)
                DispatchQueue.main.async {
                    completion(requestObject, nil)
                }
            } catch {
                do  {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }

