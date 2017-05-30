//
//  ColorPalett.swift
//  marlin-light
//
//  Created by Michael Vosseller on 5/28/17.
//  Copyright © 2017 MPV Software, LLC. All rights reserved.
//

import UIKit

class ColorPalett {
    
    static let defaultHue = 192
    static let defaultSaturation = 60
    static let defaultBrightness =  85
    
    static let maxHue = 360
    static let maxSaturation = 100
    static let maxBrightness = 100
    
    let numColors = 16
    let hue : [Int]
    let saturation : [Int]
    
    init() {
        
        var hue = [Int]()
        var saturation = [Int]()
        
        // add white
        hue.append(0)
        saturation.append(0)
        
        // autogenerate and add the rest of the colors
        let numColorsToAutoGenerate = numColors - hue.count
        let hueStep = Double(ColorPalett.maxHue) / Double(numColorsToAutoGenerate)
        
        for index in 0..<numColorsToAutoGenerate {
            hue.append(Int(hueStep * Double(index)))
            saturation.append(ColorPalett.defaultSaturation)
        }
        
        self.hue = hue
        self.saturation = saturation
    }
    
    func saturationAtIndex(_ index:Int)  -> Int {
        return self.saturation[index]
    }
    
    func hueAtIndex(_ index:Int) -> Int {
        return self.hue[index]
    }
    
    func colorAtIndex(_ index:Int, brightness:Int) -> UIColor {
        let hue = hueAtIndex(index)
        let saturation = saturationAtIndex(index)
        return colorWithHue(hue, saturation:saturation, brightness: brightness)
    }
    
    func defaultColor() -> UIColor {
        return colorWithHue(ColorPalett.defaultHue, saturation:ColorPalett.defaultSaturation, brightness:ColorPalett.defaultBrightness)
    }

    func colorWithHue(_ hue:Int, saturation:Int, brightness:Int) -> UIColor {
        let hueFloat = CGFloat(hue) / CGFloat(ColorPalett.maxHue)
        let saturationFloat = CGFloat(saturation) / CGFloat(ColorPalett.maxSaturation)
        let brightnessFloat = CGFloat(brightness) / CGFloat(ColorPalett.maxBrightness)
        let alphaFloat = CGFloat(1.0)
        return UIColor(hue:hueFloat, saturation:saturationFloat, brightness:brightnessFloat, alpha:alphaFloat)
    }
}
