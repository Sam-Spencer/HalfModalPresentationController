//
//  HalfModalTransitioningDelegate.swift
//  HalfModalPresentationController
//
//  Created by Martin Normark on 17/01/16.
//  Copyright © 2016 martinnormark. All rights reserved.
//

import UIKit

class HalfModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var viewController: UIViewController
    var presentingViewController: UIViewController
    var interactionController: HalfModalInteractiveTransition
    
    public var interactiveDismiss = true
    
    /// Percent of the screen that the presented view should cover. Needs to be a float value between 0 and 0.5.
    public var preferredPresentationPercent: CGFloat = 0.33
    
    /// When set to true, the presenting view controller will be blurred and dimmed with a vibrancy effect.
    public var dimPresenter: Bool = true
    
    /// When set to true, the presenting view controller will be animated with a scale transformation.
    public var animatePresenter: Bool = true
    
    init(viewController: UIViewController, presentingViewController: UIViewController) {
        self.viewController = viewController
        self.presentingViewController = presentingViewController
        self.interactionController = HalfModalInteractiveTransition(viewController: self.viewController, withView: self.presentingViewController.view, presentingViewController: self.presentingViewController)
        
        super.init()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HalfModalTransitionAnimator(type: .Dismiss)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = HalfModalPresentationController(presentedViewController: presented, presenting: presenting)
        controller.preferredPresentationPercentage = preferredPresentationPercent
        controller.showsDimmingView = dimPresenter
        controller.animatesPresentingView = animatePresenter
        return controller
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactiveDismiss {
            return self.interactionController
        }
        
        return nil
    }
    
}
