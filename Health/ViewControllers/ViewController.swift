//
//  ViewController.swift
//  Health
//
//  Created by Hafize on 19.08.2021.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    
    let healthStore = HealthData.healthStore
    
    /// The HealthKit data types we will request to read.
    let readTypes = Set(HealthData.readDataTypes)
    /// The HealthKit data types we will request to share and have write access.
    let shareTypes = Set(HealthData.shareDataTypes)

    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    var hasRequestedHealthData: Bool = false
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var bloodLable: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    let user = User()
    
    @IBAction func setDataClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func updateButtonClicked(_ sender: UIButton) {
        self.requestHealthAuthorization()
    }
    
    
    let healthKitStore: HKHealthStore = HKHealthStore()
    let bodyMassType = HKSampleType.quantityType(forIdentifier: .bodyMass)!
    let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeHealthKitinApp()
       
      
    }
    func requestHealthAuthorization() {
        print("Requesting HealthKit authorization...")
        
        if !HKHealthStore.isHealthDataAvailable() {
            presentHealthDataNotAvailableError()
            
            return
        }
        
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { (success, error) in
            var status: String = ""
            
            if let error = error {
                status = "HealthKit Authorization Error: \(error.localizedDescription)"
            } else {
                if success {
                    if self.hasRequestedHealthData {
                        status = "You've already requested access to health data. "
                    } else {
                        status = "HealthKit authorization request was successful! "
                    }
                    
                    status += self.createAuthorizationStatusDescription(for: self.shareTypes)
                    
                    self.hasRequestedHealthData = true
                } else {
                    status = "HealthKit authorization did not complete successfully."
                }
            }
            
            print(status)
            
            // Results come back on a background thread. Dispatch UI updates to the main thread.
            DispatchQueue.main.async {
                self.descriptionLabel.text = status
            }
        }
    }
    

    func getHealthAuthorizationRequestStatus() {
        print("Checking HealthKit authorization status...")
        
        if !HKHealthStore.isHealthDataAvailable() {
            presentHealthDataNotAvailableError()
            
            return
        }
        
        healthStore.getRequestStatusForAuthorization(toShare: shareTypes, read: readTypes) { (authorizationRequestStatus, error) in
            
            var status: String = ""
            if let error = error {
                status = "HealthKit Authorization Error: \(error.localizedDescription)"
            } else {
                switch authorizationRequestStatus {
                case .shouldRequest:
                    self.hasRequestedHealthData = false
                    
                    status = "The application has not yet requested authorization for all of the specified data types."
                case .unknown:
                    status = "The authorization request status could not be determined because an error occurred."
                case .unnecessary:
                    self.hasRequestedHealthData = true
                    
                    status = "The application has already requested authorization for the specified data types. "
                    status += self.createAuthorizationStatusDescription(for: self.shareTypes)
                default:
                    break
                }
            }
            print(status)

        }
    }
    
    
    
    private func createAuthorizationStatusDescription(for types: Set<HKObjectType>) -> String {
        var dictionary = [HKAuthorizationStatus: Int]()
        
        for type in types {
            let status = healthStore.authorizationStatus(for: type)
            
            if let existingValue = dictionary[status] {
                dictionary[status] = existingValue + 1
            } else {
                dictionary[status] = 1
            }
        }
        
        var descriptionArray: [String] = []
        
        if let numberOfAuthorizedTypes = dictionary[.sharingAuthorized] {
            let format = NSLocalizedString("AUTHORIZED_NUMBER_OF_TYPES", comment: "")
            let formattedString = String(format: format, locale: .current, arguments: [numberOfAuthorizedTypes])
            
            descriptionArray.append(formattedString)
        }
        if let numberOfDeniedTypes = dictionary[.sharingDenied] {
            let format = NSLocalizedString("DENIED_NUMBER_OF_TYPES", comment: "")
            let formattedString = String(format: format, locale: .current, arguments: [numberOfDeniedTypes])
            
            descriptionArray.append(formattedString)
        }
        if let numberOfUndeterminedTypes = dictionary[.notDetermined] {
            let format = NSLocalizedString("UNDETERMINED_NUMBER_OF_TYPES", comment: "")
            let formattedString = String(format: format, locale: .current, arguments: [numberOfUndeterminedTypes])
            
            descriptionArray.append(formattedString)
        }
        
        // Format the sentence for grammar if there are multiple clauses.
        if let lastDescription = descriptionArray.last, descriptionArray.count > 1 {
            descriptionArray[descriptionArray.count - 1] = "and \(lastDescription)"
        }
        
        let description = "Sharing is " + descriptionArray.joined(separator: ", ") + "."
        
        return description
    }

    func authorizeHealthKitinApp(){
        let healhKitTypesToRead : Set <HKObjectType> = [HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!,
                                                           HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
                                                           HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,]
        let healthKitTypesToWrite : Set <HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!]
           
           if !HKHealthStore.isHealthDataAvailable(){
               print("Error occured")
               authorizeHealthKitinApp()
               return
           }
           healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healhKitTypesToRead) { (success,error) in
            if let error = error {
                print("requestAuthorization error:", error.localizedDescription)
                self.authorizeHealthKitinApp()
        }
        
        if success {
            print("HealthKit authorization request was successful!")
            self.readProfile()
        } else {
            print("HealthKit authorization was not successful.")
        }
        
    }
       
        
       }
    
    
    /*
     class func requestHealthDataAccessIfNeeded(toShare shareTypes: Set<HKSampleType>?,
                                                read readTypes: Set<HKObjectType>?,
                                                completion: @escaping (_ success: Bool) -> Void) {
         if !HKHealthStore.isHealthDataAvailable() {
             fatalError("Health data is not available!")
         }
         
         print("Requesting HealthKit authorization...")
         healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { (success, error) in
             if let error = error {
                 print("requestAuthorization error:", error.localizedDescription)
             }
             
             if success {
                 print("HealthKit authorization request was successful!")
             } else {
                 print("HealthKit authorization was not successful.")
             }
             
             completion(success)
         }
     }
   
*/
    func readProfile(){
        var age:Int?
        var weight : String = ""
        var height : String = ""
        var gender : String = ""
        
        do{
            let birthday = try healthKitStore.dateOfBirthComponents()
            let calendar = Calendar.current
            let currentyear = calendar.component(.year, from: Date())
            age = currentyear-birthday.year!
            let query = HKSampleQuery(sampleType: bodyMassType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                if let result = results?.last as? HKQuantitySample {
                    DispatchQueue.main.async {
                        weight = "\(result.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)))"
                        if self.weightLabel != nil{
                            self.weightLabel.text = weight
                        }
                        let ages = (age ?? nil)!
                        self.ageLabel.text = "\(ages)"
                    }
                }
            }
            healthKitStore.execute(query)
        }
        catch{
            
        }
        
        do {
            let biologicalSex = try healthKitStore.biologicalSex()
            switch biologicalSex.biologicalSex.rawValue{
                case 1:gender = "female"
                case 2:gender = "male"
                case 3:gender = "other"
            default:
                gender =  ""
                
            }
            
          /*  let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                if let result = results?.last as? HKQuantitySample{
                    print("Height => \(result.quantity)")
                    DispatchQueue.main.async {
                        height = "\(result.quantity.doubleValue(for: HKUnit.meter()))"
                        if self.heightLabel != nil{
                            self.heightLabel.text = height
                        }
                    }
                }else{
                    print("OOPS didnt get height \nResults => \(results), error => \(error)")
                }
            }*/
            
            let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
                if let result = results?.first as? HKQuantitySample{
                    print("Height => \(result.quantity)")
                }else{
                    print("OOPS didnt get height \nResults => \(results), error => \(error)")
                }
            }
            self.healthKitStore.execute(query)
  
            DispatchQueue.main.async {
                if self.sexLabel != nil{
                    self.sexLabel.text = gender
                }
                if self.bloodLable != nil{
                    self.bloodLable.text = ""
                }
                
                
                
                
            }
            
            

        }
        catch{
            
        }

    }
    
    
    
    private func presentHealthDataNotAvailableError() {
        let title = "Health Data Unavailable"
        let message = "Aw, shucks! We are unable to access health data on this device. Make sure you are using device with HealthKit capabilities."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .default)
        
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
}

