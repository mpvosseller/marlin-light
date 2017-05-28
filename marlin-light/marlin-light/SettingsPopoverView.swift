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
    func numberOfColors(in settingsPopover: SettingsPopover) -> Int
    func brightness(in settingsPopover: SettingsPopover) -> Int
    func settingsPopover(_ settingsPopover: SettingsPopover, colorAt index: Int) -> UIColor
    func settingsPopover(_ settingsPopover: SettingsPopover, didSelectIndex index: Int)
    func settingsPopover(_ settingsPopover: SettingsPopover, didSelectBrightness brightness: Int)
}

class SettingsPopover: UIView {
    
    var colorLabel : UILabel!
    var buttonPanel : UIView!
    var brightnessLabel : UILabel!
    var slider : UISlider!
    var buttons : [UIButton]!
    weak var delegate : SettingsPopoverDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        commonInit()
    }
    
    func commonInit() {
        setupColorLabel()
        setupButtonPanel()
        setupBrightnessLabel()
        setupSlider()
        self.buttons = []
        
        setupLayoutContraints()
    }
    
    func setupColorLabel() {
        self.colorLabel = UILabel()
        self.colorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.colorLabel.text = "COLOR"
        self.colorLabel.textColor = UIColor(white:0.8, alpha:1.0)
        self.colorLabel.font = UIFont.boldSystemFont(ofSize:16)
        self.addSubview(self.colorLabel)
    }
    
    func setupButtonPanel() {
        self.buttonPanel = UIView()
        self.buttonPanel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonPanel)
    }
    
    func setupBrightnessLabel() {
        self.brightnessLabel = UILabel()
        self.brightnessLabel.translatesAutoresizingMaskIntoConstraints = false
        self.brightnessLabel.text = "BRIGHTNESS"
        self.brightnessLabel.textColor = UIColor(white:0.8, alpha:1.0)
        self.brightnessLabel.font = UIFont.boldSystemFont(ofSize:16)
        self.addSubview(self.brightnessLabel)
    }
    
    func setupSlider() {
        self.slider = UISlider()
        self.slider.translatesAutoresizingMaskIntoConstraints = false
        self.slider.minimumValue = 0.50
        self.addSubview(self.slider)
        self.slider.addTarget(self, action:#selector(SettingsPopover.sliderValueChanaged(_:)), for:.valueChanged)
    }
    
    func setupLayoutContraints() {
        
        let views : [String:Any] = ["colorLabel" : self.colorLabel, "buttonPanel" : self.buttonPanel, "brightnessLabel" : self.brightnessLabel, "slider" : self.slider]
        
        // color label
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"|-30-[colorLabel]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-20-[colorLabel]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        
        // button panel
        self.addConstraint(NSLayoutConstraint(item:self.buttonPanel, attribute:.left, relatedBy:.equal, toItem:self.colorLabel, attribute:.left, multiplier:1.0, constant:0.0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[colorLabel]-10-[buttonPanel]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"[buttonPanel(>=0)]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[buttonPanel(>=0)]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        
        // brightness label
        self.addConstraint(NSLayoutConstraint(item:self.brightnessLabel, attribute:.left, relatedBy:.equal, toItem:self.colorLabel, attribute:.left, multiplier:1.0, constant:0.0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[buttonPanel]-24-[brightnessLabel]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        
        // slider
        self.addConstraint(NSLayoutConstraint(item:self.slider, attribute:.left, relatedBy:.equal, toItem:self.brightnessLabel, attribute:.left, multiplier:1.0, constant:0.0))
        self.addConstraint(NSLayoutConstraint(item:self.slider, attribute:.right, relatedBy:.equal, toItem:self.buttonPanel, attribute:.right, multiplier:1.0, constant:0.0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[brightnessLabel][slider]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
    }
    
    func reloadColors() {
        
        guard let delegate = self.delegate else {
            return
        }
        
        let numColors = delegate.numberOfColors(in:self)
        
        if self.buttons.count != 0 && self.buttons.count != numColors {
            fatalError("button count can not change")
        }
        
        if self.buttons.count == 0 {
            setupButtons(numButtons:numColors)
        }
        
        for index in 0..<numColors {
            let color = delegate.settingsPopover(self, colorAt:index)
            let button = self.buttons[index]
            button.backgroundColor = color
        }
    }
    
    func reloadBrightness() {
        if let delegate = self.delegate {
            let brightness = delegate.brightness(in:self)
            self.slider.value = Float(brightness) / 100.0
        }
    }
    
    func setupButtons(numButtons:Int) {
        
        for _ in 0..<numButtons {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = 8.0
            buttons.append(button)
            button.addTarget(self, action:#selector(SettingsPopover.colorButtonPressed(_:)), for:.touchUpInside)
            buttonPanel.addSubview(button)
        }
        
        // layout the buttons and button panel
        let numColumns = 4
        var col = 0
        var row = 0
        var prevButton : UIButton? = nil
        var lastInButtonFirstRow : UIButton? = nil
        
        for b in self.buttons {
            
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
                buttonPanel.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"|[button]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            } else {
                buttonPanel.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"[prevButton]-10-[button]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            }
            
            // y pos
            if row == 0 {
                buttonPanel.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|[button]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            } else if col == 0 {
                buttonPanel.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[prevButton]-10-[button]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
            } else {
                buttonPanel.addConstraint(NSLayoutConstraint(item:b, attribute:.top, relatedBy:.equal, toItem:prevButton, attribute:.top, multiplier:1.0, constant:0.0))
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
            buttonPanel.addConstraint(NSLayoutConstraint(item:buttonPanel, attribute:.right, relatedBy:.equal, toItem:rightMostButton, attribute:.right, multiplier:1.0, constant:0.0))
        }
        
        // bottom edge of button panel
        if let bottomMostButton = prevButton {
            buttonPanel.addConstraint(NSLayoutConstraint(item:buttonPanel, attribute:.bottom, relatedBy:.equal, toItem:bottomMostButton, attribute:.bottom, multiplier:1.0, constant:0.0))
        }
    }
    
    @objc func colorButtonPressed(_ button:UIButton) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        if let index = self.buttons.index(of:button) {
            delegate.settingsPopover(self, didSelectIndex:index)
        }
    }
    
    @objc func sliderValueChanaged(_ slider:UISlider) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        let brightness = Int(slider.value * 100)
        
        delegate.settingsPopover(self, didSelectBrightness:brightness)
    }
    
}
