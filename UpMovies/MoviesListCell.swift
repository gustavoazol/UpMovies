//
//  MoviesListCell.swift
//  UpMovies
//
//  Created by Gustavo Azevedo de Oliveira on 28/08/2018.
//  Copyright © 2018 Gustavo Azevedo de Oliveira. All rights reserved.
//

import UIKit

class MoviesListCell: UITableViewCell {
    @IBOutlet weak var ivBackground: UIImageView!
    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    
    @IBOutlet weak var bgTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgBottomConstraint: NSLayoutConstraint!
    
    private var imgBackTopInitial: CGFloat!
    private var imgBackBottomInitial: CGFloat!
    private let imageParallaxFactor: CGFloat = 20
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bgBottomConstraint.constant -= 2 * imageParallaxFactor
        self.imgBackTopInitial = self.bgTopConstraint.constant
        self.imgBackBottomInitial = self.bgBottomConstraint.constant
    }
    
    func setBackgroundOffset(offset:CGFloat) {
        let boundOffset = max(0, min(1, offset))
        let pixelOffset = (1-boundOffset)*2*imageParallaxFactor
        self.bgTopConstraint.constant = self.imgBackTopInitial - pixelOffset
        self.bgBottomConstraint.constant = self.imgBackBottomInitial + pixelOffset
    }
}
