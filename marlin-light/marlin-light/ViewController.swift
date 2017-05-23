//
//  ViewController.swift
//  marlin-light
//
//  Created by Michael Vosseller on 5/22/17.
//  Copyright © 2017 MPV Software, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    lazy var availableColors : [UIColor] = {
        
        let totalColors = 16
        var colors : [UIColor] = []
        
        // hardcoded colors
        colors.append(UIColor.white)
        
        // auto generated colors
        
        // hue 0-360
        let numToGenerate = totalColors - colors.count
        let hueStep = 360.0 / Double(numToGenerate)
        var hue = 0.0
        
        while (colors.count < totalColors) {
            let color = UIColor(hue:CGFloat(hue/360.0), saturation:60.0/100.0, brightness:85.0/100.0, alpha:1.0)
            colors.append(color)
            hue += hueStep
        }
        
        return colors
    }()
    
    @IBAction func handleSettingsButtonPressed(_ sender: Any) {
        let randInt = Int(arc4random())
        let randIndex = randInt % self.availableColors.count
        let randColor = self.availableColors[randIndex]
        self.view.backgroundColor = randColor
    }

}

