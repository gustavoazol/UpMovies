//
//  Movie.swift
//  UpMovies
//
//  Created by Gustavo Azevedo de Oliveira on 28/08/2018.
//  Copyright © 2018 Gustavo Azevedo de Oliveira. All rights reserved.
//

struct Movie: Decodable {
    let id: Int
    let title: String
    let originalTitle: String
    let releaseDate: String
    let posterPath: String?
    let backdropPath: String?
    let genreIds: [Int]
    let overview: String
    
    var dateFormat: String {
        return "YYYY-MM-dd"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case originalTitle = "original_title"
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case overview
    }
}
