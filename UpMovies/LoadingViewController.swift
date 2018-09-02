//
//  LoadingViewController.swift
//  UpMovies
//
//  Created by Gustavo Azevedo de Oliveira on 29/08/2018.
//  Copyright © 2018 Gustavo Azevedo de Oliveira. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    @IBOutlet weak var svError: UIStackView!
    @IBOutlet weak var lblErrorMessage: UILabel!
    @IBOutlet weak var btnTryAgain: UIButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNeededData()
        
        lblErrorMessage.text = NSLocalizedString("initial_loading_error", comment: "Information could not be loaded. Please, try again.")
        let btnTitle = NSLocalizedString("movies_list_try_again", comment: "Try Again")
        self.btnTryAgain.setTitle(btnTitle, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.btnTryAgain.layer.cornerRadius = self.btnTryAgain.bounds.height/2
    }
    
    // MARK: Loading flow
    @IBAction func tryAgainPressed(_ sender: UIButton) {
        self.loadNeededData()
    }
    
    private func loadNeededData() {
        self.svError.isHidden = true
        self.loadingSpinner.isHidden = false
        self.loadingSpinner.startAnimating()
        
        if Configuration.current == nil {
            self.loadConfiguration()
        }
        else if Configuration.current?.genres.isEmpty == true {
            self.loadGenres()
        }
        else {
            self.performSegue(withIdentifier: "MoviesListSegue", sender: nil)
        }
    }
    
    private func showTryAgainMessage() {
        self.loadingSpinner.stopAnimating()
        self.svError.isHidden = false
    }
}


// MARK: - Loading Data Calls
extension LoadingViewController {
    private func loadConfiguration() {
        MoviesDbRestAPI.getConfiguration { [weak self] (config) in
            DispatchQueue.main.async {
                guard let configuration = config else {
                    self?.showTryAgainMessage()
                    return
                }
                
                Configuration.current = configuration
                self?.loadGenres()
            }
        }
    }
    
    private func loadGenres() {
        MoviesDbRestAPI.getGenresWithIds(completion: { [weak self] (genresDic) in
            DispatchQueue.main.async {
                guard let genres = genresDic else {
                    self?.showTryAgainMessage()
                    return
                }
                
                Configuration.current?.genres = genres
                self?.performSegue(withIdentifier: "MoviesListSegue", sender: nil)
            }
        })
    }
}
