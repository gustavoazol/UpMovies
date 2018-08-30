//
//  MovieDetailsViewController.swift
//  UpMovies
//
//  Created by Gustavo Azevedo de Oliveira on 29/08/2018.
//  Copyright © 2018 Gustavo Azevedo de Oliveira. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    @IBOutlet weak var ivBackground: UIImageView!
    @IBOutlet weak var ivPoster: UIImageView!
    
    let presenter = MovieDetailsPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fillMovieDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fillMovieDetails() {
        self.ivBackground.kf.setImage(with: self.presenter.bgUrl)
        self.ivPoster.kf.setImage(with: self.presenter.thumbUrl)
    }
    
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
