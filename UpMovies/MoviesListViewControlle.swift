//
//  ViewController.swift
//  UpMovies
//
//  Created by Gustavo Azevedo de Oliveira on 27/08/2018.
//  Copyright © 2018 Gustavo Azevedo de Oliveira. All rights reserved.
//

import UIKit
import Kingfisher

class MoviesListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var vTableLoading: UIView!
    
    let presenter = MoviesListPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.delegate = self
        self.addKeyboardObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MovieDetailsViewController,
            let selectedIndex = self.tableView.indexPathForSelectedRow {
            vc.presenter.movie = self.presenter.getMovie(forCell: selectedIndex)
        }
    }
}

// MARK: - Keyboard Insets
extension MoviesListViewController {
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        self.tableView.contentInset.bottom = keyboardSize.height
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        self.tableView.contentInset.bottom = 0.0
    }
}


// MARK: - Search Bar
extension MoviesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.presenter.searchForMovies(withText: searchText)
    }
}


// MARK: - TableView Datasource
extension MoviesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.moviesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        
        if let movieCell = cell as? MoviesListCell,
            let movieInfo = self.presenter.getMovieInfo(atIndex: indexPath) {
            movieCell.ivBackground.kf.setImage(with: movieInfo.bgUrl)
            movieCell.ivThumb.kf.setImage(with: movieInfo.thumbUrl)
            movieCell.lblTitle.text = movieInfo.title
            movieCell.lblDetails.text = movieInfo.details
        }
        
        return cell
    }
}

extension MoviesListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let maxIndex = indexPaths.max() {
            self.presenter.prefetchMovie(maxIndex: maxIndex)
        }
    }
}

// MARK: - TableView Delegate
extension MoviesListViewController: UITableViewDelegate {
    // Remouve grouped tableview insets (top and bottom)
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let movieCell = cell as? MoviesListCell {
            self.setCellImageOffset(cell: movieCell, indexPath: indexPath)
        }
        self.presenter.prefetchMovie(maxIndex: indexPath)
    }

    //MARK: Scrollview Paralax Effect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == self.tableView), let visibleIndexes = self.tableView.indexPathsForVisibleRows {
            for indexPath in visibleIndexes {
                if let movieCell = self.tableView.cellForRow(at: indexPath) as? MoviesListCell {
                    self.setCellImageOffset(cell: movieCell, indexPath: indexPath)
                }
            }
        }
    }
    
    private func setCellImageOffset(cell: MoviesListCell, indexPath: IndexPath) {
        let cellFrame = self.tableView.rectForRow(at: indexPath)
        let cellFrameInTable = self.tableView.convert(cellFrame, to:self.tableView.superview)
        let cellOffset = cellFrameInTable.origin.y + cellFrameInTable.size.height
        let tableHeight = self.tableView.bounds.size.height + cellFrameInTable.size.height
        let cellOffsetFactor = cellOffset / tableHeight
        cell.setBackgroundOffset(offset: cellOffsetFactor)
    }

}

// MARK: - Presenter Delegate
extension MoviesListViewController: MoviesListPresenterDelegate {
    func newMoviesLoaded(atIndexes indexes: [IndexPath]) {
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: indexes, with: UITableViewRowAnimation.none)
        self.tableView.endUpdates()
    }
    
    func showLoadingMoreMovies(loading: Bool) {
        self.tableView.tableFooterView = loading ? vTableLoading : nil
    }
    
    func moviesListUpdated() {
        self.tableView.reloadData()
    }
}

