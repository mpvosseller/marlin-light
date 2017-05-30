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
    
    let labelCharacterSpacing = 1.2
    let labelTextColor = UIColor(white:0.8, alpha:1.0)
    let labelFont = UIFont(name:".SFUIDisplay-Bold", size:16)
    
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
        setupColorButtons()
        setupBrightnessLabel()
        setupBrightnessSlider()
        setupLayoutContraints()
        
        refreshButtonColors()
        refreshBrightness()
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
    
    func setupColorButtons() {
        
        self.colorButtons = []
        
        let numButtons = self.delegate.colorPalette(in:self).numColors
        
        for _ in 0..<numButtons {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = 8.0
            colorButtons.append(button)
            button.addTarget(self, action:#selector(SettingsPopover.colorButtonPressed(_:)), for:.touchUpInside)
            colorButtonPanel.addSubview(button)
        }
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
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"|-30-[colorLabel]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"V:|-20-[colorLabel]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        
        // colorButtonPanel
        NSLayoutConstraint(item:self.colorButtonPanel, attribute:.left, relatedBy:.equal, toItem:self.colorLabel, attribute:.left, multiplier:1.0, constant:0.0).isActive = true
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"V:[colorLabel]-10-[colorButtonPanel]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        
        // brightnessLabel
        NSLayoutConstraint(item:self.brightnessLabel, attribute:.left, relatedBy:.equal, toItem:self.colorLabel, attribute:.left, multiplier:1.0, constant:0.0).isActive = true
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"V:[colorButtonPanel]-24-[brightnessLabel]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        
        // brightnessSlider
        NSLayoutConstraint(item:self.brightnessSlider, attribute:.left, relatedBy:.equal, toItem:self.brightnessLabel, attribute:.left, multiplier:1.0, constant:0.0).isActive = true
        NSLayoutConstraint(item:self.brightnessSlider, attribute:.right, relatedBy:.equal, toItem:self.colorButtonPanel, attribute:.right, multiplier:1.0, constant:0.0).isActive = true
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"V:[brightnessLabel]-1-[brightnessSlider]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        
        // colorButtons & colorButtonPanel
        let numColumns = 4
        var col = 0
        var row = 0
        var prevButton : UIButton? = nil
        var lastButtonInFirstRow : UIButton? = nil
        
        for button in self.colorButtons {
            
            let views : [String:Any]
            
            if let prev = prevButton {
                views = ["button" : button, "prevButton" : prev]
            } else {
                views = ["button" : button]
            }
            
            // width and height
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"[button(==32)]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"V:[button(==32)]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            
            // x position
            if col == 0 {
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"|[button]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            } else {
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"[prevButton]-10-[button]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            }
            
            // y position
            if row == 0 {
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"V:|[button]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            } else if col == 0 {
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"V:[prevButton]-10-[button]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            } else {
                NSLayoutConstraint(item:button, attribute:.top, relatedBy:.equal, toItem:prevButton, attribute:.top, multiplier:1.0, constant:0.0).isActive = true
            }
            
            if row == 0 {
                lastButtonInFirstRow = button
            }
            prevButton = button
            
            // advance to next grid position
            col += 1
            if col == numColumns {
                col = 0
                row += 1
            }
        }
        
        // right edge of colorButtonPanel
        if let rightMostButton = lastButtonInFirstRow {
            NSLayoutConstraint(item:colorButtonPanel, attribute:.right, relatedBy:.equal, toItem:rightMostButton, attribute:.right, multiplier:1.0, constant:0.0).isActive = true
        }
        
        // bottom edge of colorButtonPanel
        if let bottomMostButton = prevButton {
            NSLayoutConstraint(item:colorButtonPanel, attribute:.bottom, relatedBy:.equal, toItem:bottomMostButton, attribute:.bottom, multiplier:1.0, constant:0.0).isActive = true
        }
    }
    
    func refreshButtonColors() {
        
        let numColors = self.colorButtons.count
        
        for index in 0..<numColors {
            let button = self.colorButtons[index]
            let brightness = delegate.brightness(in:self)
            let color = self.delegate.colorPalette(in:self).colorAtIndex(index, brightness: brightness)
            button.backgroundColor = color
        }
    }
    
    func refreshBrightness() {
        let brightness = delegate.brightness(in:self)
        self.brightnessSlider.value = Float(brightness) / 100.0
    }
    
    @objc func colorButtonPressed(_ button:UIButton) {
        let index = self.colorButtons.index(of:button)!
        delegate.settingsPopover(self, didSelectColorIndex:index)
    }
    
    @objc func sliderValueChanaged(_ slider:UISlider) {
        sliderValueDidUpdate(slider, isStillAdjusting:true)
    }
    
    @objc func sliderStopped(_ slider:UISlider) {
        sliderValueDidUpdate(slider, isStillAdjusting:false)
    }
    
    func sliderValueDidUpdate(_ slider:UISlider, isStillAdjusting:Bool) {
        let brightness = Int(slider.value * 100)
        delegate.settingsPopover(self, didSelectBrightness:brightness, isStillAdjusting:isStillAdjusting)
    }
}
