//
//  Configuration.swift
//  UpMovies
//
//  Created by Gustavo Azevedo de Oliveira on 28/08/2018.
//  Copyright © 2018 Gustavo Azevedo de Oliveira. All rights reserved.
//


struct Configuration: Decodable {
    static var current: Configuration?
    
    let baseUrl: String
    let backdropSizes: [String]
    let logoSizes: [String]
    
    var genres = Dictionary<Int, String>()
    
    enum CodingKeys: String, CodingKey {
        case baseUrl = "secure_base_url"
        case backdropSizes = "backdrop_sizes"
        case logoSizes = "logo_sizes"
    }
}
