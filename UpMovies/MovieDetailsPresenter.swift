//
//  MovieDetailsPresenter.swift
//  UpMovies
//
//  Created by Gustavo Azevedo de Oliveira on 29/08/2018.
//  Copyright © 2018 Gustavo Azevedo de Oliveira. All rights reserved.
//

import UIKit

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
            return self.thumbUrl
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
    
    var attributedTitle: NSAttributedString {
        guard let movie = self.movie else {
            return NSAttributedString(string: "")
        }
        
        let attrTitle = NSMutableAttributedString(string: movie.title, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 20.0)])
        
        if movie.title != movie.originalTitle {
            let attrOriginalTitle = NSAttributedString(string: " (\(movie.originalTitle))", attributes: [NSAttributedStringKey.font : UIFont.italicSystemFont(ofSize: 16.0)])
            attrTitle.append(attrOriginalTitle)
        }
        
        return attrTitle
    }
    
    var genres: String {
        guard let movie = self.movie else {
            return ""
        }
        
        var genres = ""
        for genreId in movie.genreIds {
            if let genreName = Configuration.current?.genres[genreId] {
                genres.append("\(genreName)   ")
            }
        }
        
        return genres.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var formattedDate: String? {
        guard let movie = self.movie  else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = movie.dateFormat
        
        guard let date = dateFormatter.date(from: movie.releaseDate) else {
            return movie.releaseDate
        }
        
        dateFormatter.locale = Locale(identifier: Locale.preferredLanguages.first!)
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMMdd")
        return dateFormatter.string(from: date)
    }
    
    var movieOverview: String {
        if let overview = self.movie?.overview, !overview.isEmpty {
            let overview_intro = NSLocalizedString("movie_details_overview", comment: "Overview: ")
            return (overview_intro + "\n" + overview)
        }
        else {
            return NSLocalizedString("movie_details_overview_not_available", comment: "Overview not available")
        }
    }
}
