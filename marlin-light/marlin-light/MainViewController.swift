//
//  MainViewController.swift
//  marlin-light
//
//  Created by Michael Vosseller on 5/22/17.
//  Copyright © 2017 MPV Software, LLC. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    static let labelFontName = "Zapfino"
    static let labelFontSizeRegular : CGFloat = 31.0
    static let labelFontSizeCompact : CGFloat = 23.0
    
    let colorPalette = ColorPalette()
    let settings = Settings()

    var settingsButton: UIButton!
    var label: UILabel!
    
    override func loadView() {
        
        self.view = UIView()
        updateBackgroundColor()

        self.label = UILabel()
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.text = "Marlin Light"
        self.label.font = UIFont(name:MainViewController.labelFontName, size:MainViewController.labelFontSizeRegular)
        self.label.adjustsFontSizeToFitWidth = true
        self.label.minimumScaleFactor = 0.25
        self.label.textColor = UIColor.black
        self.label.alpha = 0.1
        self.label.textAlignment = .center
        view.addSubview(self.label)
        
        let image = UIImage(named:"marlin")!
        let imageView = UIImageView(image:image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0.03
        view.addSubview(imageView)
        
        self.settingsButton = UIButton(type: .system)
        self.settingsButton.translatesAutoresizingMaskIntoConstraints = false
        self.settingsButton.setImage(UIImage(named: "cog"), for: .normal)
        self.settingsButton.tintColor = UIColor(white: 0, alpha: 0.5)
        self.settingsButton.addTarget(self, action:#selector(handleSettingsButtonPressed(_:)), for:.touchUpInside)
        view.addSubview(self.settingsButton)
        
        // layout views
        self.label.topAnchor.constraint(equalTo:topLayoutGuide.bottomAnchor, constant:16.0).isActive = true
        self.label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.label.leadingAnchor.constraint(equalTo:view.leadingAnchor).isActive = true
        self.label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        self.label.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        
        imageView.topAnchor.constraint(equalTo: self.label.bottomAnchor, constant:-8.0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant:-4.0).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.settingsButton.widthAnchor.constraint(equalToConstant: 54).isActive = true
        self.settingsButton.heightAnchor.constraint(equalTo: self.settingsButton.widthAnchor).isActive = true
        self.settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.settingsButton.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant:-8).isActive = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        var fontSize = MainViewController.labelFontSizeRegular
        if self.traitCollection.verticalSizeClass == .compact {
            fontSize = MainViewController.labelFontSizeCompact
        }
        self.label.font = UIFont(name:MainViewController.labelFontName, size:fontSize)
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    lazy var settingsPopover : SettingsPopover = {
        
        let popover = SettingsPopover(delegate:self)
        popover.translatesAutoresizingMaskIntoConstraints = false
        popover.alpha = 0.0
        self.view.addSubview(popover)
        
        // layout views
        let bottomConstraint = popover.bottomAnchor.constraint(equalTo: self.settingsButton.topAnchor, constant:10)
        bottomConstraint.priority = UILayoutPriority.defaultLow
        bottomConstraint.isActive = true
        popover.trailingAnchor.constraint(equalTo:self.settingsButton.leadingAnchor, constant:10.0).isActive = true
        popover.topAnchor.constraint(greaterThanOrEqualTo:self.topLayoutGuide.bottomAnchor, constant:2.0).isActive = true
        
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
    
    @objc func handleSettingsButtonPressed(_ sender: Any) {
        setSettingsPopoverVisible(!isSettingsPopoverVisible())
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if viewForTouches(touches, with:event) == self.view && isSettingsPopoverVisible() {
            setSettingsPopoverVisible(false)
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
        self.settings.hue = self.colorPalette.hueAtIndex(index)
        self.settings.saturation = self.colorPalette.saturationAtIndex(index)
        updateBackgroundColor()
        self.settings.save()
    }
    
    func selectBrightness(_ brightness:Int, isStillAdjusting:Bool) {
        self.settings.brightness = brightness
        updateBackgroundColor()
        self.settingsPopover.refreshButtonColors()

        if (!isStillAdjusting) {
            self.settings.save()
        }
    }
    
    func updateBackgroundColor() {
        let color = self.colorPalette.colorWithHue(self.settings.hue, saturation: self.settings.saturation, brightness: self.settings.brightness)
        self.view.backgroundColor = color
    }
    
}

extension MainViewController : SettingsPopoverDelegate {
    
    func colorPalette(in settingsPopover: SettingsPopover) -> ColorPalette {
        return self.colorPalette
    }
    
    func brightness(in settingsPopover: SettingsPopover) -> Int {
        return self.settings.brightness
    }
    
    func settingsPopover(_ settingsPopover: SettingsPopover, didSelectColorIndex index: Int) {
        selectColorAtIndex(index)
    }
    
    func settingsPopover(_ settingsPopover: SettingsPopover, didSelectBrightness brightness: Int, isStillAdjusting:Bool) {
        selectBrightness(brightness, isStillAdjusting:isStillAdjusting)
    }
    
}

