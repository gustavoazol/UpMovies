//
//  MovieDetailsPresenter.swift
//  UpMovies
//
//  Created by Gustavo Azevedo de Oliveira on 29/08/2018.
//  Copyright © 2018 Gustavo Azevedo de Oliveira. All rights reserved.
//

import Foundation

class MovieDetailsPresenter: NSObject {
    var movie: Movie?
    
    var bgUrl: URL? {
        guard let configuration = Configuration.current else {
            return nil
        }
        
        if let path = movie?.backdropPath, let sizeString = configuration.backdropSizes.first {
            let bgUrlPath = configuration.baseUrl + sizeString + path
            return URL(string: bgUrlPath)
        }
        else {
            return nil
        }
    }
    
    var thumbUrl: URL? {
        guard let configuration = Configuration.current else {
            return nil
        }
        
        if let path = movie?.posterPath {
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
