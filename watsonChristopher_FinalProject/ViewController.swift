//
//  ViewController.swift
//  watsonChristopher_FinalProject
//
//  Created by Christopher Watson on 5/11/16.
//  Copyright © 2016 Chapman University. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var lblCatSelected: UILabel!
    @IBOutlet weak var pvCategories: UIPickerView!
    
    let catArray : [String] = ["Animals", "Cars", "Nature", "People"];
    var catName : String = "None"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.btnStart.layer.addAnimation(self.addSizePulseAnimation(), forKey: nil)
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "goToGame"){
            let destinationVC : MainGameVC = segue.destinationViewController as! MainGameVC
            
            destinationVC.catImport = catName
        }
    }

    @IBAction func tappedStartButton(sender: AnyObject) {
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return catArray.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return catArray[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        catName = catArray[row]
        lblCatSelected.text = "\(catName)"
    }
    
    func addSizePulseAnimation() -> CABasicAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: "transform")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 1
        pulseAnimation.toValue = 2
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = FLT_MAX
        return pulseAnimation
    }

}

