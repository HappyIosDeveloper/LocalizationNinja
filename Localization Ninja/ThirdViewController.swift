//
//  ThirdViewController.swift
//  Localization Ninja
//
//  Created by Ahmadreza on 5/9/21.
//

import UIKit

class ThirdViewController: UIViewController {
    
    @IBOutlet weak var staticTextLabel: UILabel!
    @IBOutlet weak var dynamicTextlabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        staticTextLabel.text = "h_1".localized()
        dynamicTextlabel.text = "h_2 %@".localize(with: 100)
    }
}
