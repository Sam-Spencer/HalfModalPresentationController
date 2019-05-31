//
//  HalfModalPresentationController.swift
//  HalfModalPresentationController
//
//  Created by Martin Normark on 17/01/16.
//  Copyright © 2016 martinnormark. All rights reserved.
//

import UIKit

enum ModalScaleState {
    case expanded
    case normal
}

class HalfModalPresentationController : UIPresentationController {
    
    public var showsDimmingView: Bool = true
    public var animatesPresentingView: Bool = true
    
    public var preferredPresentationPercentage: CGFloat = 0.33 {
        didSet {
            if preferredPresentationPercentage > 0.5 {
                preferredPresentationPercentage = 0.5
            }
            
            if preferredPresentationPercentage < 0.0 {
                preferredPresentationPercentage = 0.0
            }
        }
    }
    
    var calculatedPresentationPercentage: CGFloat {
        get {
            return 1.0 - preferredPresentationPercentage
        }
    }
    
    var isMaximized: Bool = false
    
    var _dimmingView: UIView?
    var panGestureRecognizer: UIPanGestureRecognizer
    var tapGestureRecognizer: UITapGestureRecognizer
    var direction: CGFloat = 0
    var state: ModalScaleState = .normal
    var dimmingView: UIView {
        if let dimmedView = _dimmingView {
            return dimmedView
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height))
        
        if self.showsDimmingView == true {
            // Blur Effect
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            view.addSubview(blurEffectView)
            
            // Vibrancy Effect
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
            vibrancyEffectView.frame = view.bounds
            
            // Add the vibrancy view to the blur view
            blurEffectView.contentView.addSubview(vibrancyEffectView)
        }
        
        _dimmingView = view
        
        return view
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.panGestureRecognizer = UIPanGestureRecognizer()
        self.tapGestureRecognizer = UITapGestureRecognizer()
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        panGestureRecognizer.addTarget(self, action: #selector(onPan(pan:)))
        presentedViewController.view.addGestureRecognizer(panGestureRecognizer)
        
        tapGestureRecognizer.addTarget(self, action: #selector(onTap(tap:)))
    }
    
    @objc func onTap(tap: UITapGestureRecognizer) {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) {
        let endPoint = pan.translation(in: pan.view?.superview)
        switch pan.state {
        case .began:
            presentedView!.frame.size.height = containerView!.frame.height
        case .changed:
            let velocity = pan.velocity(in: pan.view?.superview)
            print(velocity.y)
            switch state {
            case .normal:
                presentedView!.frame.origin.y = endPoint.y + containerView!.frame.height * calculatedPresentationPercentage
            case .expanded:
                presentedView!.frame.origin.y = endPoint.y
            }
            direction = velocity.y
            break
        case .ended:
            if direction < 0 {
                changeScale(to: .expanded)
            } else {
                if state == .expanded {
                    changeScale(to: .normal)
                } else {
                    presentedViewController.dismiss(animated: true, completion: nil)
                }
            }
            print("finished transition")
            break
        default:
            break
        }
    }
    
    func changeScale(to state: ModalScaleState) {
        if let presentedView = presentedView, let containerView = self.containerView {
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { () -> Void in
                presentedView.frame = containerView.frame
                let containerFrame = containerView.frame
                let halfFrame = CGRect(origin: CGPoint(x: 0, y: containerFrame.height * self.calculatedPresentationPercentage),
                                       size: CGSize(width: containerFrame.width, height: containerFrame.height * self.calculatedPresentationPercentage))
                let frame = state == .expanded ? containerView.frame : halfFrame
                
                presentedView.frame = frame
                
                if let navController = self.presentedViewController as? UINavigationController {
                    self.isMaximized = state == .expanded ? true : false
                    navController.setNeedsStatusBarAppearanceUpdate()
                    
                    // Force the navigation bar to update its size
                    navController.isNavigationBarHidden = true
                    navController.isNavigationBarHidden = false
                }
            }, completion: { (isFinished) in
                self.state = state
            })
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0, y: containerView!.bounds.height * calculatedPresentationPercentage, width: containerView!.bounds.width, height: containerView!.bounds.height * calculatedPresentationPercentage)
    }
    
    override func presentationTransitionWillBegin() {
        let dimmedView = dimmingView
        
        if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator {
            dimmedView.alpha = 0
            containerView.addSubview(dimmedView)
            dimmedView.addSubview(presentedViewController.view)
            dimmingView.addGestureRecognizer(tapGestureRecognizer)
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
                dimmedView.alpha = 1
                self.presentingViewController.view.transform = self.animatesPresentingView ? CGAffineTransform(scaleX: 0.95, y: 0.95) : CGAffineTransform.identity
                self.presentedViewController.view.layer.shadowOpacity = 0.2
                self.presentedViewController.view.layer.shadowColor = UIColor.black.cgColor
                self.presentedViewController.view.layer.shadowRadius = 10.0
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (context) -> Void in
                self.dimmingView.alpha = 0
                self.presentingViewController.view.transform = CGAffineTransform.identity
            }, completion: { (completed) -> Void in
                print("Done dismiss animation")
            })
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        print("Dismissal did end: \(completed)")
        if completed {
            dimmingView.removeFromSuperview()
            dimmingView.removeGestureRecognizer(tapGestureRecognizer)
            _dimmingView = nil
            isMaximized = false
        }
    }
}

protocol HalfModalPresentable { }

extension HalfModalPresentable where Self: UIViewController {
    
    func maximizeToFullScreen() -> Void {
        if let presentation = navigationController?.presentationController as? HalfModalPresentationController {
            presentation.changeScale(to: .expanded)
            return
        }
        
        if let presentation = self.presentationController as? HalfModalPresentationController {
            presentation.changeScale(to: .expanded)
            return
        }
    }
    
    func minimizeToHalfScreen() -> Void {
        if let presentation = navigationController?.presentationController as? HalfModalPresentationController {
            presentation.changeScale(to: .normal)
            return
        }
        
        if let presentation = self.presentationController as? HalfModalPresentationController {
            presentation.changeScale(to: .normal)
            return
        }
    }
    
    func isMaximized() -> Bool {
        if let presentation = navigationController?.presentationController as? HalfModalPresentationController {
            return presentation.isMaximized
        }
        
        if let presentation = self.presentationController as? HalfModalPresentationController {
            presentation.changeScale(to: .normal)
            return presentation.isMaximized
        }
        
        return false
    }
}

extension HalfModalPresentable where Self: UINavigationController {
    
    func isHalfModalMaximized() -> Bool {
        if let presentationController = presentationController as? HalfModalPresentationController {
            return presentationController.isMaximized
        }
        
        return false
    }
    
}
