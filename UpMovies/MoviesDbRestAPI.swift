//
//  MoviesDbRestAPI.swift
//  UpMovies
//
//  Created by Gustavo Azevedo de Oliveira on 27/08/2018.
//  Copyright © 2018 Gustavo Azevedo de Oliveira. All rights reserved.
//

import Foundation


class MoviesDbRestAPI: NSObject {
    private static let TMDB_API_KEY: String = "1f54bd990f1cdfb230adb312546d765d"
    private static let HOST_AND_VERSION: String = "https://api.themoviedb.org"
    
    class func getConfiguration(completion: @escaping (_ config: Configuration?)->Void) {
        let path = "/3/configuration"
        let method = "GET"
        
        self.executeRequest(path: path, httpMethod: method) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil)
            }
            else if let returnedData = data {
                do {
                    guard let jsonDic = try JSONSerialization.jsonObject(with: returnedData, options: .mutableContainers) as? Dictionary<String, Any> else {
                        completion(nil)
                        return
                    }
                    
                    guard let imagesConfig = jsonDic["images"] else {
                        completion(nil)
                        return
                    }
                    
                    let configData = try JSONSerialization.data(withJSONObject: imagesConfig, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let config = try JSONDecoder().decode(Configuration.self, from: configData)
                    completion(config)
                }
                catch {
                    print(error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }
    
    class func getUpcomingMovies(completion: @escaping (_ results: [Movie])->Void) {
        let path = "/3/movie/upcoming"
        let method = "GET"
        
        self.executeRequest(path: path, httpMethod: method) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                completion([])
            }
            else if let returnedData = data {
                do {
                    guard let jsonDic = try JSONSerialization.jsonObject(with: returnedData, options: .mutableContainers) as? Dictionary<String, Any> else {
                        completion([])
                        return
                    }
                    
                    guard let moviesJson = jsonDic["results"] else {
                        completion([])
                        return
                    }
                    
                    let moviesData = try JSONSerialization.data(withJSONObject: moviesJson, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let movies = try JSONDecoder().decode([Movie].self, from: moviesData)
                    completion(movies)
                }
                catch {
                    print(error.localizedDescription)
                    completion([])
                }
            }
        }
    }
    
    private class func executeRequest(path: String, queryItems: [URLQueryItem]? = nil, httpMethod: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        guard var urlComponents = URLComponents(string: HOST_AND_VERSION) else {
            fatalError("Could not create URL from components")
        }
        urlComponents.path = path
        
        var query = [
            URLQueryItem(name: "api_key", value: TMDB_API_KEY),
            URLQueryItem(name: "language", value: Locale.preferredLanguages.first)
        ]
        
        if let queryItems = queryItems {
            query.append(contentsOf: queryItems)
        }
        urlComponents.queryItems = query
        
        guard let url = urlComponents.url else {
            fatalError("Could not create URL from components")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.httpShouldHandleCookies = false
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request, completionHandler: completion)
        task.resume()
    }
}
