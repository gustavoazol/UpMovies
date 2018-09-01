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
    func showLoadingMoreMovies(loading: Bool)
    func newMoviesLoaded(atIndexes indexes: [IndexPath])
}

class MoviesListPresenter: NSObject {
    private var moviesList = [Movie]()
    
    private var isLoadingMovies = false
    private var searchWorkItem: DispatchWorkItem?

    let interactor = MoviesListInteractor()
    weak var delegate: MoviesListPresenterDelegate?
    
    override init() {
        super.init()
        self.fetchMovies()
    }
    
    private func fetchMovies() {
        self.isLoadingMovies = true
        self.interactor.fetchMovies { [weak self] (success, movies) in
            guard success else {
                // show error
                return
            }
            
            self?.isLoadingMovies = false
            self?.moviesList = movies
            self?.delegate?.moviesListUpdated()
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
        self.delegate?.showLoadingMoreMovies(loading: true)
        
        self.interactor.loadMoreMovies { [weak self] (success, movies) in
            guard success else {
                // show error
                return
            }
            
            self?.isLoadingMovies = false
            self?.delegate?.showLoadingMoreMovies(loading: false)
            
            self?.moviesList.append(contentsOf: movies)
            self?.delegate?.moviesListUpdated()
            
            /*
             var newIndexes = [IndexPath]()
             for i in 0..<newMovies.count {
             let row = (self?.moviesList.count ?? 0) + i
             let indexPath = IndexPath(row: row, section: 0)
             newIndexes.append(indexPath)
             }
             
             self?.delegate?.newMoviesLoaded(atIndexes: newIndexes)
             */
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
        self.fetchMovies()
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
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMMdd")
        return dateFormatter.string(from: date)
    }
}
