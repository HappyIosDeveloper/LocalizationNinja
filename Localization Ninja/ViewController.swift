//
//  ViewController.swift
//  Localization Ninja
//
//  Created by Ahmadreza on 5/9/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var segmentView: UISegmentedControl!
    @IBAction func segmentViewAction(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Locale.updateLanguage(language: (self.segmentView.titleForSegment(at: 0)?.isFarsi ?? true) ? "en" : "fa")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reverseSegmentTitle((self.segmentView.titleForSegment(at: 0)?.isFarsi ?? true))
    }
    
    func reverseSegmentTitle(_ reverse:Bool) {
        let item1 = segmentView.titleForSegment(at: reverse ? 1 : 0)
        let item0 = segmentView.titleForSegment(at: reverse ? 0 : 1)
        segmentView.removeAllSegments()
        segmentView.insertSegment(withTitle: item0, at: reverse ? 0 : 1, animated: true)
        segmentView.insertSegment(withTitle: item1, at: !reverse ? 0 : 1, animated: true)
        segmentView.handleDirection(isRightToLeft: true)
        segmentView.selectedSegmentIndex = reverse ? 1 : 0
    }
}

