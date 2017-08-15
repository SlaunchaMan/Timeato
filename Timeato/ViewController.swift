//
//  ViewController.swift
//  Timeato
//
//  Created by Jeff Kelley on 6/2/17.
//  Copyright © 2017 Jeff Kelley. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    public var timerEndDate: Date?
    
    lazy var timerPreviewFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        
        formatter.unitsStyle = .positional
        
        return formatter
    }()
    
    @IBOutlet weak var timerLabel: UILabel?
    var displayLink: CADisplayLink?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let displayLink = CADisplayLink(target: self,
                                        selector: #selector(displayLinkFired(_:)))
        
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    @objc private func displayLinkFired(_ displayLink: CADisplayLink) {
        if let timerEndDate = timerEndDate {
            timerLabel?.text = timerPreviewFormatter.string(from: Date(), to: timerEndDate)
        }
        else {
            timerLabel?.text = timerPreviewFormatter.string(from: 25 * 60)
        }
    }
    
}
