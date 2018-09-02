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
        let path = "/configuration"
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
    
    class func getGenresWithIds(completion: @escaping (_ genresDic: Dictionary<Int, String>?)->Void) {
        let path = "/genre/movie/list"
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
                    
                    guard let genresJson = jsonDic["genres"] as? [Dictionary<String, Any>] else {
                        completion(nil)
                        return
                    }
                    
                    var genresDic = Dictionary<Int, String>()
                    for genre in genresJson {
                        if let genreId = genre["id"] as? Int {
                            genresDic[genreId] = (genre["name"] as? String)
                        }
                    }
                    
                    completion(genresDic)
                }
                catch {
                    print(error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }
    
    
    // MARK: - Default Request
    private class func executeRequest(path: String, queryItems: [URLQueryItem]? = nil, httpMethod: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        guard var urlComponents = URLComponents(string: HOST_AND_VERSION) else {
            fatalError("Could not create URL from components")
        }
        urlComponents.path = "/3\(path)"
        
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

// MARK: - Movies Fetch
extension MoviesDbRestAPI {
    class func getUpcomingMovies(page: Int? = nil, completion: @escaping (_ newPage: Int, _ maxPages: Int, _ results: [Movie]?)->Void) {
        let path = "/movie/upcoming"
        let method = "GET"
        
        var queryItems: [URLQueryItem]? = nil
        if let wantedPage = page {
            queryItems = [URLQueryItem(name: "page", value: "\(wantedPage)")]
        }
        
        self.executeRequest(path: path, queryItems: queryItems, httpMethod: method) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                completion(0, 0, nil)
            }
            else if let returnedData = data {
                do {
                    let decoded = try self.decodeMoviesResult(resultData: returnedData)
                    completion(decoded.page, decoded.maxPage, decoded.movies)
                }
                catch {
                    print(error.localizedDescription)
                    completion(0, 0, nil)
                }
            }
            else {
                completion(0, 0, nil)
            }
        }
    }
    
    class func searchMovies(page: Int? = nil, query: String, completion: @escaping (_ newPage: Int, _ maxPages: Int, _ results: [Movie]?)->Void) {
        let path = "/search/movie"
        let method = "GET"
        
        let pageString = (page != nil) ? "\(page!)" : nil
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: pageString),
            URLQueryItem(name: "query", value: query)
        ]
        
        self.executeRequest(path: path, queryItems: queryItems, httpMethod: method) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                completion(0, 0, nil)
            }
            else if let returnedData = data {
                do {
                    let decoded = try self.decodeMoviesResult(resultData: returnedData)
                    completion(decoded.page, decoded.maxPage, decoded.movies)
                }
                catch {
                    print(error.localizedDescription)
                    completion(0, 0, nil)
                }
            }
            else {
                completion(0, 0, nil)
            }
        }
    }
    
    private class func decodeMoviesResult(resultData: Data) throws -> (page: Int, maxPage: Int, movies: [Movie]?) {
        guard let jsonDic = try JSONSerialization.jsonObject(with: resultData, options: .mutableContainers) as? Dictionary<String, Any> else {
            return (0, 0, nil)
        }
        
        guard let newPage = jsonDic["page"] as? Int, let maxPages = jsonDic["total_pages"] as? Int, let moviesJson = jsonDic["results"] else {
            return (0, 0, nil)
        }
        
        let moviesData = try JSONSerialization.data(withJSONObject: moviesJson, options: JSONSerialization.WritingOptions.prettyPrinted)
        let movies = try JSONDecoder().decode([Movie].self, from: moviesData)
        return (newPage, maxPages, movies)
    }
}
