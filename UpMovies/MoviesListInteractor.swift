//
//  MoviesListInteractor.swift
//  UpMovies
//
//  Created by Gustavo Azevedo de Oliveira on 30/08/2018.
//  Copyright © 2018 Gustavo Azevedo de Oliveira. All rights reserved.
//

import UIKit

class MoviesListInteractor: NSObject {
    private var page: Int?
    private var maxPage: Int?
    var searchTerm: String = "" {
        didSet {
            if searchTerm != oldValue {
                self.clearPages()
            }
        }
    }
    
    var hasMoreMoviesToFetch: Bool {
        guard let page = self.page, let maxPage = self.maxPage else {
            return true
        }
        return page < maxPage
    }
    
    func fetchMovies(completion: @escaping (_ movies: [Movie])->Void) {
        self.clearPages()
        self.loadMoreMovies(completion: completion)
    }
    
    func loadMoreMovies(completion: @escaping (_ movies: [Movie])->Void) {
        if self.searchTerm.isEmpty {
            self.fetchUpcomingMovies(completion: completion)
        }
        else {
            self.searchMovies(withTerm: self.searchTerm, completion: completion)
        }
    }
    
    private func fetchUpcomingMovies(completion: @escaping (_ movies: [Movie])->Void) {
        guard hasMoreMoviesToFetch else {
            completion([])
            return
        }
        
        let pageToFetch = self.getPageToFetch()
        MoviesDbRestAPI.getUpcomingMovies(page: pageToFetch) { [weak self] (page, maxPage, movies) in
            DispatchQueue.main.async {
                self?.page = page
                self?.maxPage = maxPage
                completion(movies)
            }
        }
    }
    
    private func searchMovies(withTerm term: String, completion: @escaping (_ movies: [Movie])->Void) {
        guard hasMoreMoviesToFetch else {
            completion([])
            return
        }
        
        let pageToFetch = self.getPageToFetch()
        MoviesDbRestAPI.searchMovies(page: pageToFetch, query: term) { [weak self] (page, maxPage, movies) in
            DispatchQueue.main.async {
                self?.page = page
                self?.maxPage = maxPage
                completion(movies)
            }
        }
    }
    
    private func clearPages() {
        self.page = nil
        self.maxPage = nil
    }
    
    private func getPageToFetch() -> Int? {
        if let currentPage = self.page {
            return currentPage + 1
        }
        return nil
    }
}
