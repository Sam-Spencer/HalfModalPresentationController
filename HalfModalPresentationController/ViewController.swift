//
//  ViewController.swift
//  HalfModalPresentationController
//
//  Created by Martin Normark on 17/01/16.
//  Copyright © 2016 martinnormark. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    @IBOutlet weak var dimPresenterSwitch: UISwitch!
    @IBOutlet weak var animatePresenterSwitch: UISwitch!
    @IBOutlet weak var presentationPercentSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: segue.destination)
        self.halfModalTransitioningDelegate?.preferredPresentationPercent = CGFloat(presentationPercentSlider.value)
        self.halfModalTransitioningDelegate?.animatePresenter = animatePresenterSwitch.isOn
        self.halfModalTransitioningDelegate?.dimPresenter = dimPresenterSwitch.isOn
        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = self.halfModalTransitioningDelegate
    }

}

