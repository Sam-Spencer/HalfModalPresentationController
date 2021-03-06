//
//  ModalViewController.swift
//  HalfModalPresentationController
//
//  Created by Martin Normark on 17/01/16.
//  Copyright © 2016 martinnormark. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController, HalfModalPresentable {
    
    @IBAction func maximizeButtonTapped(sender: UIBarButtonItem) {
        if isMaximized() {
            minimizeToHalfScreen()
            sender.title = "Expand"
        } else {
            maximizeToFullScreen()
            sender.title = "Shrink"
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }
}
