//
//  LoadingViewController.swift
//  UpMovies
//
//  Created by Gustavo Azevedo de Oliveira on 29/08/2018.
//  Copyright © 2018 Gustavo Azevedo de Oliveira. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadConfiguration()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadConfiguration() {
        MoviesDbRestAPI.getConfiguration { [weak self] (config) in
            DispatchQueue.main.async {
                guard let configuration = config else {
                    // Show error
                    return
                }
                
                Configuration.current = configuration
                MoviesDbRestAPI.getGenresWithIds(completion: { (genresDic) in
                    DispatchQueue.main.async {
                        Configuration.current?.genres = genresDic
                        self?.performSegue(withIdentifier: "MoviesListSegue", sender: nil)
                    }
                })
            }
        }
    }
}
