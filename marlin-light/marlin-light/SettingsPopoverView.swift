//
//  SettingsView.swift
//  marlin-light
//
//  Created by Michael Vosseller on 5/23/17.
//  Copyright © 2017 MPV Software, LLC. All rights reserved.
//

import Foundation
import UIKit


protocol SettingsPopoverDelegate: class {
    func colorPalette(in settingsPopover: SettingsPopover) -> ColorPalette
    func brightness(in settingsPopover: SettingsPopover) -> Int
    func settingsPopover(_ settingsPopover: SettingsPopover, didSelectColorIndex index: Int)
    func settingsPopover(_ settingsPopover: SettingsPopover, didSelectBrightness brightness: Int, isStillAdjusting:Bool)
}

class SettingsPopover: UIView {
    
    let labelCharacterSpacing = 1.0
    let labelTextColor = UIColor(white:0.8, alpha:1.0)
    let labelFont = UIFont.boldSystemFont(ofSize:16)
    
    var colorLabel : UILabel!
    var colorButtonPanel : UIView!
    var colorButtons : [UIButton]!
    var brightnessLabel : UILabel!
    var brightnessSlider : UISlider!
    
    weak var delegate : SettingsPopoverDelegate!
    
    init(delegate:SettingsPopoverDelegate) {
        self.delegate = delegate
        super.init(frame:CGRect.zero)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("method not supported")
    }
    
    func commonInit() {
        setupColorLabel()
        setupColorButtonPanel()
        self.colorButtons = []
        setupBrightnessLabel()
        setupBrightnessSlider()
        setupLayoutContraints()
    }
    
    func setupColorLabel() {
        self.colorLabel = UILabel()
        self.colorLabel.translatesAutoresizingMaskIntoConstraints = false
        let text = "COLOR"
        let attributedString = NSMutableAttributedString(string:text)
        attributedString.addAttribute(NSKernAttributeName, value:labelCharacterSpacing, range: NSMakeRange(0, text.characters.count))
        self.colorLabel.attributedText = attributedString
        self.colorLabel.textColor = labelTextColor
        self.colorLabel.font = labelFont
        self.addSubview(self.colorLabel)
    }
    
    func setupColorButtonPanel() {
        self.colorButtonPanel = UIView()
        self.colorButtonPanel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(colorButtonPanel)
    }
    
    func setupBrightnessLabel() {
        self.brightnessLabel = UILabel()
        self.brightnessLabel.translatesAutoresizingMaskIntoConstraints = false
        let text = "BRIGHTNESS"
        let attributedString = NSMutableAttributedString(string:text)
        attributedString.addAttribute(NSKernAttributeName, value:labelCharacterSpacing, range: NSMakeRange(0, text.characters.count))
        self.brightnessLabel.attributedText = attributedString
        self.brightnessLabel.textColor = labelTextColor
        self.brightnessLabel.font = labelFont
        self.addSubview(self.brightnessLabel)
    }
    
    func setupBrightnessSlider() {
        self.brightnessSlider = UISlider()
        self.brightnessSlider.translatesAutoresizingMaskIntoConstraints = false
        self.brightnessSlider.minimumValue = 0.50
        self.brightnessSlider.tintColor = self.delegate.colorPalette(in:self).defaultColor()
        self.brightnessSlider.addTarget(self, action:#selector(SettingsPopover.sliderValueChanaged(_:)), for:.valueChanged)
        self.brightnessSlider.addTarget(self, action:#selector(SettingsPopover.sliderStopped(_:)), for:.touchUpInside)
        self.brightnessSlider.addTarget(self, action:#selector(SettingsPopover.sliderStopped(_:)), for:.touchUpOutside)
        self.addSubview(self.brightnessSlider)
    }
    
    func setupLayoutContraints() {
        
        let views : [String:Any] = ["colorLabel" : self.colorLabel, "colorButtonPanel" : self.colorButtonPanel, "brightnessLabel" : self.brightnessLabel, "brightnessSlider" : self.brightnessSlider]
        
        // colorLabel
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"|-30-[colorLabel]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-20-[colorLabel]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        
        // colorButtonPanel
        self.addConstraint(NSLayoutConstraint(item:self.colorButtonPanel, attribute:.left, relatedBy:.equal, toItem:self.colorLabel, attribute:.left, multiplier:1.0, constant:0.0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[colorLabel]-10-[colorButtonPanel]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"[colorButtonPanel(>=0)]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[colorButtonPanel(>=0)]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        
        // brightnessLabel
        self.addConstraint(NSLayoutConstraint(item:self.brightnessLabel, attribute:.left, relatedBy:.equal, toItem:self.colorLabel, attribute:.left, multiplier:1.0, constant:0.0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[colorButtonPanel]-24-[brightnessLabel]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        
        // brightnessSlider
        self.addConstraint(NSLayoutConstraint(item:self.brightnessSlider, attribute:.left, relatedBy:.equal, toItem:self.brightnessLabel, attribute:.left, multiplier:1.0, constant:0.0))
        self.addConstraint(NSLayoutConstraint(item:self.brightnessSlider, attribute:.right, relatedBy:.equal, toItem:self.colorButtonPanel, attribute:.right, multiplier:1.0, constant:0.0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[brightnessLabel][brightnessSlider]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
    }
    
    func reloadColors() {
        
        let numColors = self.delegate.colorPalette(in:self).numColors
        
        if self.colorButtons.count != 0 && self.colorButtons.count != numColors {
            fatalError("button count can not change")
        }
        
        if self.colorButtons.count == 0 {
            setupButtons(numButtons:numColors)
        }
        
        for index in 0..<numColors {
            let brightness = delegate.brightness(in:self)
            let color = self.delegate.colorPalette(in:self).colorAtIndex(index, brightness: brightness)
            let button = self.colorButtons[index]
            button.backgroundColor = color
        }
    }
    
    func reloadBrightness() {
        if let delegate = self.delegate {
            let brightness = delegate.brightness(in:self)
            self.brightnessSlider.value = Float(brightness) / 100.0
        }
    }
    
    func setupButtons(numButtons:Int) {
        
        for _ in 0..<numButtons {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = 8.0
            colorButtons.append(button)
            button.addTarget(self, action:#selector(SettingsPopover.colorButtonPressed(_:)), for:.touchUpInside)
            colorButtonPanel.addSubview(button)
        }
        
        // layout the buttons and button panel
        let numColumns = 4
        var col = 0
        var row = 0
        var prevButton : UIButton? = nil
        var lastInButtonFirstRow : UIButton? = nil
        
        for b in self.colorButtons {
            
            let views : [String:Any]
            
            if let prev = prevButton {
                views = ["button" : b, "prevButton" : prev]
            } else {
                views = ["button" : b]
            }
            
            // size
            b.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"[button(==32)]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            b.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[button(==32)]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            
            // x pos
            if col == 0 {
                colorButtonPanel.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"|[button]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            } else {
                colorButtonPanel.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"[prevButton]-10-[button]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            }
            
            // y pos
            if row == 0 {
                colorButtonPanel.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|[button]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            } else if col == 0 {
                colorButtonPanel.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[prevButton]-10-[button]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            } else {
                colorButtonPanel.addConstraint(NSLayoutConstraint(item:b, attribute:.top, relatedBy:.equal, toItem:prevButton, attribute:.top, multiplier:1.0, constant:0.0))
            }
            
            if row == 0 {
                lastInButtonFirstRow = b
            }
            prevButton = b
            
            // advance to next grid position
            col += 1
            if col == numColumns {
                col = 0
                row += 1
            }
        }
        
        // right edge of button panel
        if let rightMostButton = lastInButtonFirstRow {
            colorButtonPanel.addConstraint(NSLayoutConstraint(item:colorButtonPanel, attribute:.right, relatedBy:.equal, toItem:rightMostButton, attribute:.right, multiplier:1.0, constant:0.0))
        }
        
        // bottom edge of button panel
        if let bottomMostButton = prevButton {
            colorButtonPanel.addConstraint(NSLayoutConstraint(item:colorButtonPanel, attribute:.bottom, relatedBy:.equal, toItem:bottomMostButton, attribute:.bottom, multiplier:1.0, constant:0.0))
        }
    }
    
    @objc func colorButtonPressed(_ button:UIButton) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        if let index = self.colorButtons.index(of:button) {
            delegate.settingsPopover(self, didSelectColorIndex:index)
        }
    }
    
    @objc func sliderValueChanaged(_ slider:UISlider) {
        sliderValueUpdated(slider, isStillAdjusting:true)
    }
    
    @objc func sliderStopped(_ slider:UISlider) {
        sliderValueUpdated(slider, isStillAdjusting:false)
    }
    
    func sliderValueUpdated(_ slider:UISlider, isStillAdjusting:Bool) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        let brightness = Int(slider.value * 100)
        
        delegate.settingsPopover(self, didSelectBrightness:brightness, isStillAdjusting:isStillAdjusting)
        
    }
    
    
}
