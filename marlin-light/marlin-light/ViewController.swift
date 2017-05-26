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
    
    let numColors = 16
    let numColumns = 4
    let saturation = 60 // 0-100
    let brightness = 85 // 0-100
    
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
        
        
        popover.reloadColors()
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
    
    
    
    func settingsPopover(_ settingsPopover: SettingsPopover, didSelectIndex index: Int) {
        let color = self.settingsPopover(settingsPopover, colorAt: index)
        self.view.backgroundColor = color
    }
    
    func numberOfColors(in settingsPopover: SettingsPopover) -> Int {
        return self.numColors
    }
    
    func numberOfColumns(in settingsPopover: SettingsPopover) -> Int {
        return self.numColumns
    }
    
    
    func settingsPopover(_ settingsPopover: SettingsPopover, colorAt index: Int) -> UIColor {
        if index >= self.numColors {
            fatalError()
        }
        
        if index == 0 {
            return UIColor(hue:0.0, saturation:0.0, brightness:CGFloat(self.brightness)/100.0, alpha:1.0)
        } else {
            let hueStep = 360.0 / Double(numColors - 1)
            let hue = hueStep * Double((index - 1))
            return UIColor(hue:CGFloat(hue/360.0), saturation:CGFloat(self.saturation)/100.0, brightness:CGFloat(self.brightness)/100.0, alpha:1.0)
        }
    }
    
    
    
}

