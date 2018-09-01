//
//  MoviesListPresenter.swift
//  UpMovies
//
//  Created by Gustavo Azevedo de Oliveira on 28/08/2018.
//  Copyright © 2018 Gustavo Azevedo de Oliveira. All rights reserved.
//

import Foundation

protocol MoviesListPresenterDelegate: class {
    func moviesListUpdated()
    func showLoadingMovies(loading: Bool, full: Bool)
    func showErrorLoadingMovies()
}

class MoviesListPresenter: NSObject {
    private var moviesList = [Movie]()
    
    private var isLoadingMovies = false
    private var searchWorkItem: DispatchWorkItem?

    let interactor = MoviesListInteractor()
    weak var delegate: MoviesListPresenterDelegate?
    
    func loadMoviesList() {
        self.isLoadingMovies = true
        self.delegate?.showLoadingMovies(loading: true, full: true)
        
        self.interactor.fetchMovies { [weak self] (success, movies) in
            self?.delegate?.showLoadingMovies(loading: false, full: true)
            self?.isLoadingMovies = false
            
            self?.moviesList = movies
            self?.delegate?.moviesListUpdated()
            if !success {
                self?.delegate?.showErrorLoadingMovies()
            }
        }
    }
    
    func prefetchMovie(maxIndex: IndexPath) {
        guard self.interactor.hasMoreMoviesToFetch, !isLoadingMovies else {
            return
        }
        
        guard maxIndex.row == self.moviesCount - 1 else {
            return
        }
        
        self.isLoadingMovies = true
        self.delegate?.showLoadingMovies(loading: true, full: false)
        
        self.interactor.loadMoreMovies { [weak self] (success, movies) in
            self?.delegate?.showLoadingMovies(loading: false, full: false)
            self?.isLoadingMovies = false

            guard success else {
                print("Error loading more movies")
                return
            }
            
            self?.moviesList.append(contentsOf: movies)
            self?.delegate?.moviesListUpdated()
        }
    }
    
    func getMovie(forCell indexPath: IndexPath) -> Movie? {
        guard indexPath.row < self.moviesList.count else {
            return nil
        }
        return self.moviesList[indexPath.row]
    }
}


// MARK: - Search Movies
extension MoviesListPresenter {
    func searchForMovies(withText text: String) {
        self.searchWorkItem?.cancel()

        let dispatchWorkItem = DispatchWorkItem(block: { [weak self] in
            self?.reloadMoviesList(forTerm: text)
        })
        
        self.searchWorkItem = dispatchWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: dispatchWorkItem)
    }
    
    private func reloadMoviesList(forTerm searchTerm: String) {
        guard self.interactor.searchTerm != searchTerm else {
            return
        }
        
        self.interactor.searchTerm = searchTerm
        self.loadMoviesList()
    }
}

// MARK: - Controller Access
extension MoviesListPresenter {
    var moviesCount: Int {
        return self.moviesList.count
    }
    
    func getMovieInfo(atIndex indexPath: IndexPath) -> (bgUrl: URL?, thumbUrl: URL?, title: String, details: String)? {
        guard indexPath.row < self.moviesCount else {
            return nil
        }
        
        let movie = self.moviesList[indexPath.row]
        let thumbUrl: URL? = self.thumbUrl(forMovie: movie)
        let bgUrl: URL? = self.bgUrl(forMovie: movie) ?? thumbUrl
        let description = self.formattedDate(fromMovie: movie)
        return (bgUrl, thumbUrl, movie.title, description)
    }
    
    private func bgUrl(forMovie movie: Movie) -> URL? {
        guard let configuration = Configuration.current else {
            return nil
        }
        
        if let path = movie.backdropPath, let sizeString = configuration.backdropSizes.first {
            let bgUrlPath = configuration.baseUrl + sizeString + path
            return URL(string: bgUrlPath)
        }
        else {
            return nil
        }
    }
    
    private func thumbUrl(forMovie movie: Movie) -> URL? {
        guard let configuration = Configuration.current else {
            return nil
        }
        
        if let path = movie.posterPath {
            let sizeString = configuration.logoSizes[1]
            let thumbUrlPath = configuration.baseUrl + sizeString + path
            return URL(string: thumbUrlPath)
        }
        else {
            return nil
        }
    }
    
    private func formattedDate(fromMovie movie: Movie) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = movie.dateFormat
        
        guard let date = dateFormatter.date(from: movie.releaseDate) else {
            return movie.releaseDate
        }
        
        dateFormatter.locale = Locale(identifier: Locale.preferredLanguages.first!)
        dateFormatter.setLocalizedDateFormatFromTemplate("YYYMMMMdd")
        return dateFormatter.string(from: date)
    }
}
