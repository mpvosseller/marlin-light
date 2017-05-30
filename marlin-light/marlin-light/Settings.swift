//
//  Settings.swift
//  marlin-light
//
//  Created by Michael Vosseller on 5/29/17.
//  Copyright © 2017 MPV Software, LLC. All rights reserved.
//

import Foundation

class Settings {
    
    static let hueKey = "hue"
    static let saturationKey = "saturation"
    static let brightnessKey = "brightness"
    
    var hue = 0
    var saturation = 0
    var brightness = 0
    
    init() {
        load()
    }
    
    func load() {
        let userDefaults = UserDefaults.standard
        self.hue = userDefaults.value(forKey:Settings.hueKey) as? Int ?? ColorPalette.defaultHue
        self.saturation = userDefaults.value(forKey:Settings.saturationKey) as? Int ?? ColorPalette.defaultSaturation
        self.brightness = userDefaults.value(forKey:Settings.brightnessKey) as? Int ?? ColorPalette.defaultBrightness
    }
    
    func save() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(self.hue, forKey:Settings.hueKey)
        userDefaults.setValue(self.saturation, forKey:Settings.saturationKey)
        userDefaults.setValue(self.brightness, forKey:Settings.brightnessKey)
        userDefaults.synchronize()
    }    
}

