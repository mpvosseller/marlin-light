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
    func settingsPopover(_ settingsPopover: SettingsPopover, colorAt index: Int) -> UIColor
    func settingsPopover(_ settingsPopover: SettingsPopover, didSelectIndex index: Int)
}

class SettingsPopover: UIView {
    
    var label : UILabel!
    var divider : UIView!
    var buttonPanel : UIView!
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
        setupLabel()
        setupDivider()
        setupButtonPanel()
        self.buttons = []
    }
    
    func setupLabel() {
        self.label = UILabel()
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.text = "SELECT COLOR"
        self.label.textColor = UIColor(white:0.8, alpha:1.0)
        self.label.font = UIFont.boldSystemFont(ofSize:16)
        self.addSubview(self.label)
        
        let views : [String:Any] = ["label" : self.label]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"|-31-[label]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-16-[label]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
    }
    
    func setupDivider() {
        self.divider = UIView()
        self.divider.translatesAutoresizingMaskIntoConstraints = false
        self.divider.backgroundColor = self.label.textColor
        self.addSubview(self.divider)
        
        let views : [String:Any] = ["label" : self.label, "divider" : self.divider]
        
        // XXX remove hardcoded width
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"|-31-[divider(==158)]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[label]-4-[divider(==2)]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
    }
    
    func setupButtonPanel() {
        self.buttonPanel = UIView()
        self.buttonPanel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonPanel)
        
        let views : [String:Any] = ["divider" : self.divider, "buttonPanel" : buttonPanel]
        self.addConstraint(NSLayoutConstraint(item:self.buttonPanel, attribute:.left, relatedBy:.equal, toItem:self.divider, attribute:.left, multiplier:1.0, constant:0.0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[divider]-29-[buttonPanel]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        
        // XXX width and height get defined by the buttons once created. do we need to specify a low priority default size for it?
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
    
}
