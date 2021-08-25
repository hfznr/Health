//
//  SecondViewController.swift
//  Health
//
//  Created by Hafize on 25.08.2021.
//

import UIKit


class SecondViewController: UIViewController {
    
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var heightTextField: UITextField!
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.weightTextField?.placeholder = user.getUserWeight()
        self.heightTextField?.placeholder = user.getUserHeight()
        
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        user.writeToKit(weightText:self.weightTextField?.text!, heightText: self.heightTextField?.text!)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
