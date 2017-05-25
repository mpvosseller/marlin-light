//
//  ViewController.swift
//  marlin-light
//
//  Created by Michael Vosseller on 5/22/17.
//  Copyright © 2017 MPV Software, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SettingsPopoverDelegate {
    
    var settingsPopover : SettingsPopover?
    @IBOutlet var settingsButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSettingsView()
    }
    
    func setupSettingsView() {
        
        if !self.isViewLoaded {
            fatalError()
        }
        
        let popover = SettingsPopover()
        popover.delegate = self
        popover.colors = self.availableColors
        self.view.addSubview(popover)
        self.settingsPopover = popover
        
        popover.translatesAutoresizingMaskIntoConstraints = false
        popover.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        popover.alpha = 0.0
        popover.layer.cornerRadius = 10
        popover.layer.shadowOffset = CGSize(width:2, height:2)
        popover.layer.shadowRadius = 4;
        popover.layer.shadowOpacity = 0.4;
        
        // XXX remove hardcoded width and height
        self.view.addConstraint(NSLayoutConstraint(item:popover, attribute:.width, relatedBy:.equal, toItem:nil, attribute:.width, multiplier:1.0, constant:222))
        self.view.addConstraint(NSLayoutConstraint(item:popover, attribute:.height, relatedBy:.equal, toItem:nil, attribute:.height, multiplier:1.0, constant:275))
        self.view.addConstraint(NSLayoutConstraint(item:popover, attribute:.right, relatedBy:.equal, toItem:self.settingsButton, attribute:.left, multiplier:1.0, constant:-6.0))
        self.view.addConstraint(NSLayoutConstraint(item:popover, attribute:.bottom, relatedBy:.equal, toItem:self.settingsButton, attribute:.top, multiplier:1.0, constant:-6.0))
    }
    
    func isSettingsPopoverVisible() -> Bool {
        
        guard let popover = self.settingsPopover else {
            fatalError()
        }
        
        if popover.alpha > 0 {
            return true
        } else {
            return false
        }
    }
    
    func showSettingsPopover() {
        if !isSettingsPopoverVisible() {
            toggleSettingsPopover()
        }
    }
    
    func hideSettingsPopover() {
        if isSettingsPopoverVisible() {
            toggleSettingsPopover()
        }
    }
    
    func toggleSettingsPopover() {
        
        guard let popover = self.settingsPopover else {
            fatalError()
        }
        
        UIView.animate(withDuration: 0.10) {
            if popover.alpha > 0 {
                popover.alpha = 0.0
            } else {
                popover.alpha = 1.0
            }
        }
    }
    
    lazy var availableColors : [UIColor] = {
        
        let totalColors = 16
        var colors : [UIColor] = []
        
        // hardcoded colors
        colors.append(UIColor.white)
        
        // auto generated colors
        
        // hue 0-360
        let numToGenerate = totalColors - colors.count
        let hueStep = 360.0 / Double(numToGenerate)
        var hue = 0.0
        
        while (colors.count < totalColors) {
            let color = UIColor(hue:CGFloat(hue/360.0), saturation:60.0/100.0, brightness:85.0/100.0, alpha:1.0)
            colors.append(color)
            hue += hueStep
        }
        
        return colors
    }()
    
    @IBAction func handleSettingsButtonPressed(_ sender: Any) {
        toggleSettingsPopover()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in:self.view) {
            if let view = self.view?.hitTest(point, with:event) {
                if view == self.view {
                    if isSettingsPopoverVisible() {
                        hideSettingsPopover()
                    }
                }
            }
        }
    }
    
    func settingsPopoverDidSelectColor(_ color:UIColor) {
        self.view.backgroundColor = color
    }
}

