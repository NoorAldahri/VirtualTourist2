// noor
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Noor Aldahri on 07/10/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import MapKit

struct FlickrAPI {
    
    static func getPhotoUrls(with coordinate: CLLocationCoordinate2D, pageNumber: Int, completion: @escaping ([URL]?, Error?, String?) -> ()) {
        let methodParameters = [
            "method": "flickr.photos.search",
            "api_key": "85b45f09bb51332cc9827e3fdfa6090d",
            "bbox": bboxString(for: coordinate),
            "safe_search": "1",
            "extras": "url_m",
            "format": "json",
            "nojsoncallback": "1",
            "page": pageNumber,
            "per_page": 6,
            ] as [String:Any]
        
        let request = URLRequest(url: getURL(from: methodParameters))
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard (error == nil) else {
                completion(nil, error, nil)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion(nil, nil, "The status code other than 200")
                return
            }
            
            guard let data = data else {
                completion(nil, nil, "No data!")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any] else {
                completion(nil, nil, "Couldn't parse data as JSON.")
                return
            }
            
            guard let stat = result["stat"] as? String, stat == "ok" else {
                completion(nil, nil, "Flickr API returned an error.")
                return
            }
            
            guard let photoDictionary = result["photos"] as? [String:Any] else {
                completion(nil, nil, "Cannot find key 'photos')")
                return
            }
            
            guard let photosArray = photoDictionary["photo"] as? [[String:Any]] else {
                completion(nil, nil, "Cannot find photo")
                return
            }
            
            var photosURLs = [URL]()
            for photoDictionary in photosArray {
                guard let urlString = photoDictionary["url_m"] as? String else {
                    return
                }
                let url = URL(string: urlString)
                photosURLs.append(url!)
            }
            completion(photosURLs, nil, nil)
        }
        task.resume()
        
    }
    
    static func bboxString(for coordinate: CLLocationCoordinate2D) -> String {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let minimumLon = max(longitude - 1.0, -180)
        let minimumLat = max(latitude - 1.0, -90)
        let maximumLon = min(longitude + 1.0, 180)
        let maximumLat = min(latitude + 1.0, 90)
        
        return "\(minimumLon), \(minimumLat), \(maximumLon), \(maximumLat)"
    }
    
    static func getURL(from parameters: [String:Any]) -> URL {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem (name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
}
