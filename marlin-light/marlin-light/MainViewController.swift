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
    let colorPalett = ColorPalett()
    let settings = Settings()
    
    override func loadView() {
        
        //
        // create views
        //
        
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
        
        
        //
        // layout views
        //
        
        let views : [String:Any] = ["label" : label, "imageView" : imageView, "settingsButton" : self.settingsButton]
        
        // label
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"|-8-[label]-8-|", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"V:|-20-[label]", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        label.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)

        // imageView
        NSLayoutConstraint(item:imageView, attribute:.centerX, relatedBy:.equal, toItem:view, attribute:.centerX, multiplier:1.0, constant:0.0).isActive = true
        NSLayoutConstraint(item:imageView, attribute:.top, relatedBy:.equal, toItem:label, attribute:.bottom, multiplier:1.0, constant:-20.0).isActive = true
        NSLayoutConstraint(item:imageView, attribute:.bottom, relatedBy:.lessThanOrEqual, toItem:view, attribute:.bottom, multiplier:1.0, constant:0.0).isActive = true
        
        let c = NSLayoutConstraint(item:imageView, attribute:.bottom, relatedBy:.equal, toItem:view, attribute:.bottom, multiplier:1.0, constant:-10.0)
        c.priority = UILayoutPriorityDefaultLow
        c.isActive = true
        
        let aspectRatio = image.size.width / image.size.height
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio).isActive = true
        
        // settingsButton
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"[settingsButton(==54)]-8-|", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat:"V:[settingsButton(==54)]-8-|", options:NSLayoutFormatOptions(rawValue:0), metrics:nil, views:views))
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
        NSLayoutConstraint(item:popover, attribute:.width, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant:222).isActive = true
        NSLayoutConstraint(item:popover, attribute:.height, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant:300).isActive = true
        
        // top
        NSLayoutConstraint(item:popover, attribute:.top, relatedBy:.greaterThanOrEqual, toItem:self.view, attribute:.top, multiplier:1.0, constant:6.0).isActive = true
        
        // bottom
        var bottomConstraint = NSLayoutConstraint(item:popover, attribute:.bottom, relatedBy:.equal, toItem:self.settingsButton, attribute:.top, multiplier:1.0, constant:10.0)
        bottomConstraint.priority = UILayoutPriorityDefaultLow
        bottomConstraint.isActive = true

        // right
        NSLayoutConstraint(item:popover, attribute:.right, relatedBy:.equal, toItem:self.settingsButton, attribute:.left, multiplier:1.0, constant:10.0).isActive = true
        
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

extension MainViewController : SettingsPopoverDelegate {
    
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

