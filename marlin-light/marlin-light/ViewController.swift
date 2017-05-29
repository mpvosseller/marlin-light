//
//  ViewController.swift
//  marlin-light
//
//  Created by Michael Vosseller on 5/22/17.
//  Copyright © 2017 MPV Software, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
        
    @IBOutlet var settingsButton: UIButton?
    
    let colorPalett = ColorPalett()
    let settings = Settings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBackgroundColor()
        self.settingsButton?.tintColor = UIColor(white: 0, alpha: 0.5)
    }
    
    lazy var settingsPopover : SettingsPopover = {
        let popover = SettingsPopover()
        popover.delegate = self
        popover.translatesAutoresizingMaskIntoConstraints = false
        popover.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        popover.alpha = 0.0
        popover.layer.cornerRadius = 10
        popover.layer.shadowOffset = CGSize(width:2, height:2)
        popover.layer.shadowRadius = 4;
        popover.layer.shadowOpacity = 0.4;
        
        self.view.addSubview(popover)
        
        // XXX remove hardcoded width and height
        self.view.addConstraint(NSLayoutConstraint(item:popover, attribute:.width, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant:222))
        self.view.addConstraint(NSLayoutConstraint(item:popover, attribute:.height, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant:300))
        
        // top
        self.view.addConstraint(NSLayoutConstraint(item:popover, attribute:.top, relatedBy:.greaterThanOrEqual, toItem:self.view, attribute:.top, multiplier:1.0, constant:6.0))
        
        // bottom
        var bottomConstraint = NSLayoutConstraint(item:popover, attribute:.bottom, relatedBy:.equal, toItem:self.settingsButton, attribute:.top, multiplier:1.0, constant:-6.0)
        bottomConstraint.priority = UILayoutPriorityDefaultLow
        self.view.addConstraint(bottomConstraint)

        // right
        self.view.addConstraint(NSLayoutConstraint(item:popover, attribute:.right, relatedBy:.equal, toItem:self.settingsButton, attribute:.left, multiplier:1.0, constant:-6.0))
        
        popover.reloadColors()
        popover.reloadBrightness()
        
        return popover
    }()
    
    func isSettingsPopoverVisible() -> Bool {
        return self.settingsPopover.alpha > 0.0
    }
    
    func setSettingsPopoverVisible(_ visible:Bool) {
        UIView.animate(withDuration:0.10, animations: {
            self.settingsPopover.alpha = visible ? 1.0 : 0.0
        })
    }
    
    @IBAction func handleSettingsButtonPressed(_ sender: Any) {
        setSettingsPopoverVisible(!isSettingsPopoverVisible())
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if viewForTouches(touches, with:event) == self.view {
            if isSettingsPopoverVisible() {
                setSettingsPopoverVisible(false)
            }
        }
    }
    
    func viewForTouches(_ touches: Set<UITouch>, with event: UIEvent?) -> UIView? {
        
        var view : UIView?
        
        if let point = touches.first?.location(in:self.view) {
            view = self.view?.hitTest(point, with:event)
        }
        return view
    }
    
    func selectColorAtIndex(_ index:Int) {
        self.settings.hue = self.colorPalett.hueAtIndex(index)
        self.settings.saturation = self.colorPalett.saturationAtIndex(index)
        updateBackgroundColor()
        self.settings.save()
    }
    
    func selectBrightness(_ brightness:Int, isStillAdjusting:Bool) {
        self.settings.brightness = brightness
        updateBackgroundColor()
        self.settingsPopover.reloadColors()

        if (!isStillAdjusting) {
            self.settings.save()
        }
    }
    
    func updateBackgroundColor() {
        let color = self.colorPalett.colorWithHue(self.settings.hue, saturation: self.settings.saturation, brightness: self.settings.brightness)
        self.view.backgroundColor = color
    }
    
}

extension ViewController : SettingsPopoverDelegate {
    
    func numberOfColors(in settingsPopover: SettingsPopover) -> Int {
        return self.colorPalett.numColors
    }
    
    func brightness(in settingsPopover: SettingsPopover) -> Int {
        return self.settings.brightness
    }
    
    func settingsPopover(_ settingsPopover: SettingsPopover, colorAt index: Int) -> UIColor {
        return self.colorPalett.colorAtIndex(index, brightness:self.settings.brightness)
    }
    
    func settingsPopover(_ settingsPopover: SettingsPopover, didSelectIndex index: Int) {
        selectColorAtIndex(index)
    }
    
    func settingsPopover(_ settingsPopover: SettingsPopover, didSelectBrightness brightness: Int, isStillAdjusting:Bool) {
        selectBrightness(brightness, isStillAdjusting:isStillAdjusting)
    }
    
}

