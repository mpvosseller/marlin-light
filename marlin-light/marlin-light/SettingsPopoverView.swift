//
//  SettingsPopoverView.swift
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
    var colorButtons : [UIButton]!
    var brightnessLabel : UILabel!
    var brightnessSlider : UISlider!
    
    var verticalStackView : UIStackView!
    var colorButtonGrid : UIStackView!
    
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
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.layer.cornerRadius = 10
        self.layer.shadowOffset = CGSize(width:2, height:2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.4
        
        setupColorLabel()
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
    }
    
    func setupBrightnessSlider() {
        self.brightnessSlider = UISlider()
        self.brightnessSlider.translatesAutoresizingMaskIntoConstraints = false
        self.brightnessSlider.minimumValue = 0.50
        self.brightnessSlider.tintColor = self.delegate.colorPalette(in:self).defaultColor()
        self.brightnessSlider.addTarget(self, action:#selector(SettingsPopover.sliderValueChanaged(_:)), for:.valueChanged)
        self.brightnessSlider.addTarget(self, action:#selector(SettingsPopover.sliderStopped(_:)), for:.touchUpInside)
        self.brightnessSlider.addTarget(self, action:#selector(SettingsPopover.sliderStopped(_:)), for:.touchUpOutside)
    }
    
    func setupLayoutContraints() {
        
        setupColorButtonGridLayoutContraints()
        
        // add some variable spacing
        let spacer1 = UIView()
        spacer1.translatesAutoresizingMaskIntoConstraints = false
        spacer1.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        let spacer2 = UIView()
        spacer2.translatesAutoresizingMaskIntoConstraints = false
        spacer2.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        let spacer3 = UIView()
        spacer3.translatesAutoresizingMaskIntoConstraints = false
        spacer3.heightAnchor.constraint(equalToConstant: 4).isActive = true
        
        self.verticalStackView = UIStackView(arrangedSubviews: [self.colorLabel, spacer1, self.colorButtonGrid, spacer2, self.brightnessLabel, spacer3, self.brightnessSlider])
        self.verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        self.verticalStackView.axis = .vertical
        self.verticalStackView.alignment = .leading
        self.verticalStackView.spacing = 0
        self.addSubview(self.verticalStackView)
        
        self.verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant:30.0).isActive = true
        self.verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant:-30.0).isActive = true
        self.verticalStackView.topAnchor.constraint(equalTo: self.topAnchor, constant:21.0).isActive = true
        self.verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:-30.0).isActive = true

        self.brightnessSlider.trailingAnchor.constraint(equalTo: self.verticalStackView.trailingAnchor).isActive = true
    }

    func setupColorButtonGridLayoutContraints() {
        
        self.colorButtonGrid = UIStackView()
        self.colorButtonGrid.translatesAutoresizingMaskIntoConstraints = false
        self.colorButtonGrid.axis = .vertical
        self.colorButtonGrid.spacing = 10
        
        var rowStackView : UIStackView?
        for button in self.colorButtons {
            
            button.widthAnchor.constraint(equalToConstant: 32).isActive = true
            button.heightAnchor.constraint(equalTo:button.widthAnchor).isActive = true
            
            if rowStackView == nil {
                rowStackView = UIStackView()
                rowStackView!.translatesAutoresizingMaskIntoConstraints = false
                rowStackView!.axis = .horizontal
                rowStackView!.spacing = 10
                self.colorButtonGrid.addArrangedSubview(rowStackView!)
            }
            
            rowStackView!.addArrangedSubview(button)
            
            if (rowStackView!.arrangedSubviews.count == 4) {
                rowStackView = nil
            }
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
