//
//  ViewController.swift
//  Health
//
//  Created by Hafize on 19.08.2021.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    var hasRequestedHealthData: Bool = false
    @IBOutlet weak var sexLabel: UILabel?
    @IBOutlet weak var ageLabel: UILabel?
    @IBOutlet weak var bloodLable: UILabel?
    @IBOutlet weak var weightLabel: UILabel?
    @IBOutlet weak var heightLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    
    let user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user.authorizeHealthKitinApp()
        readUserInfo()
        
    }
    
    
    @IBAction func setData(_ sender: Any) {
        self.performSegue(withIdentifier: "secondPage", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier  == "secondPage" {
            let destination = segue.destination as! SecondViewController
            destination.user =  self.user
        }
    }
    
    @IBAction func updateButtonClicked(_ sender: UIButton) {
        readUserInfo()
    }
    
    func readUserInfo(){
        user.readProfile()
        DispatchQueue.main.async {
            self.sexLabel?.text = self.user.getUserSex()
            self.ageLabel?.text = self.user.getUserAge()
            self.heightLabel?.text = self.user.getUserHeight()
            self.weightLabel?.text = self.user.getUserWeight()
            self.bloodLable?.text = self.user.getUserBlood()
        }
    }
}

