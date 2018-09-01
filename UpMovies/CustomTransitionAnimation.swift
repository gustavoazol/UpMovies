//
//  TransitionNavController.swift
//  UpMovies
//
//  Created by Gustavo Azevedo de Oliveira on 01/09/2018.
//  Copyright © 2018 Gustavo Azevedo de Oliveira. All rights reserved.
//

import UIKit

class CustomTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval
    let isPresenting: Bool
    let referenceFrame: CGRect
    let transitionImage: UIImageView
    
    init(duration: TimeInterval, isPresenting: Bool, referenceFrame: CGRect, image: UIImage?) {
        self.duration = duration
        self.isPresenting = isPresenting
        self.referenceFrame = referenceFrame
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        self.transitionImage = imageView
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from),
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
                return
        }
        
        self.isPresenting ? container.addSubview(toView) : container.insertSubview(toView, belowSubview: fromView)
        
        let transitionView = isPresenting ? toView : fromView
        container.insertSubview(transitionImage, belowSubview: transitionView)
        
        transitionView.clipsToBounds = true
        transitionView.backgroundColor = .clear
        if isPresenting {
            transitionView.frame = self.referenceFrame
            transitionView.alpha = 0.0
        }
        
        self.transitionImage.frame = transitionView.frame
        container.layoutIfNeeded()
        
        let finalFrame = isPresenting ? container.bounds : self.referenceFrame
        let finalAlpha: CGFloat = isPresenting ? 1.0 : 0.0
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            self.transitionImage.frame = finalFrame
            transitionView.frame = finalFrame
            transitionView.alpha = finalAlpha
            transitionView.layoutIfNeeded()
        }) { (_) in
            self.transitionImage.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
