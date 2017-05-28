//
//  ViewController.swift
//  marlin-light
//
//  Created by Michael Vosseller on 5/22/17.
//  Copyright © 2017 MPV Software, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    static let hueKey = "hue"
    static let saturationKey = "saturation"
    static let brightnessKey = "brightness"
    
    @IBOutlet var settingsButton: UIButton?
    
    let colorPallett = ColorPallett()
    var hue = 0
    var saturation = 0
    var brightness = 0
   
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadHsb()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBackgroundColor()
    }
    
    func loadHsb() {
        let userDefaults = UserDefaults.standard
        self.hue = userDefaults.value(forKey:ViewController.hueKey) as? Int ?? colorPallett.defaultHue
        self.saturation = userDefaults.value(forKey:ViewController.saturationKey) as? Int ?? colorPallett.defaultSaturation
        self.brightness = userDefaults.value(forKey:ViewController.brightnessKey) as? Int ?? colorPallett.defaultBrightness
    }
    
    func saveHsb() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(self.hue, forKey:ViewController.hueKey)
        userDefaults.setValue(self.saturation, forKey:ViewController.saturationKey)
        userDefaults.setValue(self.brightness, forKey:ViewController.brightnessKey)
        userDefaults.synchronize()
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
        self.view.addConstraint(NSLayoutConstraint(item:popover, attribute:.height, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant:275))
        self.view.addConstraint(NSLayoutConstraint(item:popover, attribute:.right, relatedBy:.equal, toItem:self.settingsButton, attribute:.left, multiplier:1.0, constant:-6.0))
        self.view.addConstraint(NSLayoutConstraint(item:popover, attribute:.bottom, relatedBy:.equal, toItem:self.settingsButton, attribute:.top, multiplier:1.0, constant:-6.0))
        
        popover.reloadColors()
        
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
        self.hue = self.colorPallett.hueAtIndex(index)
        self.saturation = self.colorPallett.saturationAtIndex(index)
        updateBackgroundColor()
        saveHsb()
    }
    
    func selectBrightness(_ brightness:Int) {
        self.brightness = brightness
        updateBackgroundColor()
        self.settingsPopover.reloadColors()
        saveHsb()
    }
    
    func updateBackgroundColor() {
        let color = self.colorPallett.colorWithHue(self.hue, saturation: self.saturation, brightness: self.brightness)
        self.view.backgroundColor = color
    }
    
}

extension ViewController : SettingsPopoverDelegate {
    
    func numberOfColors(in settingsPopover: SettingsPopover) -> Int {
        return self.colorPallett.numColors
    }
    
    func settingsPopover(_ settingsPopover: SettingsPopover, colorAt index: Int) -> UIColor {
        return self.colorPallett.colorAtIndex(index, brightness:self.brightness)
    }
    
    func settingsPopover(_ settingsPopover: SettingsPopover, didSelectIndex index: Int) {
        selectColorAtIndex(index)
    }
}

