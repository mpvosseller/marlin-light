//
//  MainViewController.swift
//  marlin-light
//
//  Created by Michael Vosseller on 5/22/17.
//  Copyright © 2017 MPV Software, LLC. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var settingsButton: UIButton!
    let colorPalette = ColorPalette()
    let settings = Settings()
    
    override func loadView() {
        
        // create views
        self.view = UIView()
        updateBackgroundColor()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Marlin Light"
        label.font = UIFont(name:"Zapfino", size:31.0)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.25
        label.textColor = UIColor.black
        label.alpha = 0.1
        label.textAlignment = .center
        view.addSubview(label)
        
        let image = UIImage(named:"marlin")!
        let imageView = UIImageView(image:image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0.03
        view.addSubview(imageView)
        
        self.settingsButton = UIButton(type: .system)
        self.settingsButton.translatesAutoresizingMaskIntoConstraints = false
        self.settingsButton.setImage(UIImage(named: "cog"), for: .normal)
        self.settingsButton.tintColor = UIColor(white: 0, alpha: 0.5)
        self.settingsButton.addTarget(self, action:#selector(MainViewController.handleSettingsButtonPressed(_:)), for:.touchUpInside)
        view.addSubview(self.settingsButton)
                
        // layout views
        label.leadingAnchor.constraint(equalTo:view.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo:view.trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo:topLayoutGuide.bottomAnchor, constant:16).isActive = true
        label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: (image.size.width / image.size.height)).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant:-4).isActive = true
        imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomLayoutGuide.topAnchor).isActive = true
        
        self.settingsButton.widthAnchor.constraint(equalToConstant: 54).isActive = true
        self.settingsButton.heightAnchor.constraint(equalTo: self.settingsButton.widthAnchor).isActive = true
        self.settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.settingsButton.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant:-8).isActive = true
    }
        
    lazy var settingsPopover : SettingsPopover = {
        
        let popover = SettingsPopover(delegate:self)
        popover.translatesAutoresizingMaskIntoConstraints = false
        popover.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        popover.alpha = 0.0
        popover.layer.cornerRadius = 10
        popover.layer.shadowOffset = CGSize(width:2, height:2)
        popover.layer.shadowRadius = 4;
        popover.layer.shadowOpacity = 0.4;
        
        self.view.addSubview(popover)
                
        let bottomConstraint = popover.bottomAnchor.constraint(equalTo: self.settingsButton.topAnchor, constant:10)
        bottomConstraint.priority = UILayoutPriorityDefaultLow
        bottomConstraint.isActive = true

        popover.trailingAnchor.constraint(equalTo:self.settingsButton.leadingAnchor, constant:10.0).isActive = true
        popover.topAnchor.constraint(greaterThanOrEqualTo:self.topLayoutGuide.bottomAnchor, constant:6.0).isActive = true
        
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

