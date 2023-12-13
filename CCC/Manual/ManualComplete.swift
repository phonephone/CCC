//
//  ManualComplete.swift
//  CCC
//
//  Created by Truk Karawawattana on 4/2/2565 BE.
//

import UIKit

class ManualComplete: UIViewController {
    
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MANUAL COMPLETE")
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
