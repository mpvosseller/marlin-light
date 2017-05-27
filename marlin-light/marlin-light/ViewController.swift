//
//  ViewController.swift
//  marlin-light
//
//  Created by Michael Vosseller on 5/22/17.
//  Copyright © 2017 MPV Software, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    static let numColors = 16
    static let numColumns = 4
    
    static let defaultHue = 192
    static let defaultSaturation = 60
    static let defaultBrightness = 85

    var hue = defaultHue // 0-360
    var saturation = defaultSaturation // 0-100
    var brightness = defaultBrightness // 0-100
    
    @IBOutlet var settingsButton: UIButton?
    
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
        
        if let h = userDefaults.value(forKey:"hue") as? Int {
            if h >= 0 || h <= 100 {
                self.hue = h
            }
        }
        
        if let s = userDefaults.value(forKey:"saturation") as? Int {
            if s >= 0 || s <= 100 {
                self.saturation = s
            }
        }

        if let b = userDefaults.value(forKey:"brightness") as? Int {
            if b >= 0 || b <= 100 {
                self.brightness = b
            }
        }
    }
    
    func saveHsb() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(self.hue, forKey:"hue")
        userDefaults.setValue(self.saturation, forKey:"saturation")
        userDefaults.setValue(self.brightness, forKey:"brightness")
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
    
    func colorWithHue(_ hue:Int, saturation:Int) -> UIColor {
        return colorWithHue(hue, saturation:saturation, brightness:self.brightness)
    }
    
    func colorWithCurrentHSB() -> UIColor {
        return colorWithHue(self.hue, saturation:self.saturation, brightness:self.brightness)
    }
    
    func colorWithHue(_ hue:Int, saturation:Int, brightness:Int) -> UIColor {
        let hueFloat = CGFloat(hue) / 360.0
        let saturationFloat = CGFloat(saturation) / 100.0
        let brightnessFloat = CGFloat(brightness) / 100.0
        let alphaFloat = CGFloat(1.0)
        return UIColor(hue:hueFloat, saturation:saturationFloat, brightness:brightnessFloat, alpha:alphaFloat)
    }
    
    func hueAtIndex(_ index:Int) -> Int {
        if index == 0 {
            // white
            return 0
        } else {
            let numGeneratedColors = ViewController.numColors - 1 // exclude harcoded colors
            let hueStep = 360 / Double(numGeneratedColors)
            let hue = hueStep * Double((index - 1))
            return Int(hue)
        }
    }
    
    func saturationAtIndex(_ index:Int) -> Int {
        if index == 0 {
            // white
            return 0
        } else {
            return ViewController.defaultSaturation
        }
    }

    func colorAtIndex(_ index:Int) -> UIColor {
        if index >= ViewController.numColors {
            fatalError()
        }
        
        let hue = hueAtIndex(index)
        let saturation = saturationAtIndex(index)
        return colorWithHue(hue, saturation:saturation)
    }
    
    func selectColorAtIndex(_ index:Int) {
        self.hue = hueAtIndex(index)
        self.saturation = saturationAtIndex(index)
        updateBackgroundColor()
        saveHsb()
    }
    
    func updateBackgroundColor() {
        let color = colorWithCurrentHSB()
        self.view.backgroundColor = color
    }
    
}


extension ViewController : SettingsPopoverDelegate {
    
    func numberOfColors(in settingsPopover: SettingsPopover) -> Int {
        return ViewController.numColors
    }
    
    func numberOfColumns(in settingsPopover: SettingsPopover) -> Int {
        return ViewController.numColumns
    }
    
    func settingsPopover(_ settingsPopover: SettingsPopover, colorAt index: Int) -> UIColor {
        return colorAtIndex(index)
    }
    
    func settingsPopover(_ settingsPopover: SettingsPopover, didSelectIndex index: Int) {
        selectColorAtIndex(index)
    }
}

