//
//  ColorPalett.swift
//  marlin-light
//
//  Created by Michael Vosseller on 5/28/17.
//  Copyright © 2017 MPV Software, LLC. All rights reserved.
//

import Foundation
import UIKit

class ColorPalett {
    
    let defaultHue = 192
    let defaultSaturation = 60
    let defaultBrightness =  85
    
    let maxHue = 360
    let maxSaturation = 100
    let maxBrightness = 100
    
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
        let hueStep = Double(maxHue) / Double(numColorsToAutoGenerate)
        
        for index in 0..<numColorsToAutoGenerate {
            let h = Int(hueStep * Double(index))
            hue.append(h)
            saturation.append(defaultSaturation)
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
    
    func colorWithHue(_ hue:Int, saturation:Int, brightness:Int) -> UIColor {
        let hueFloat = CGFloat(hue) / CGFloat(maxHue)
        let saturationFloat = CGFloat(saturation) / CGFloat(maxSaturation)
        let brightnessFloat = CGFloat(brightness) / CGFloat(maxBrightness)
        let alphaFloat = CGFloat(1.0)
        return UIColor(hue:hueFloat, saturation:saturationFloat, brightness:brightnessFloat, alpha:alphaFloat)
    }
    
}
