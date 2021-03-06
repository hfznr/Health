//
//  User.swift
//  Health
//
//  Created by Hafize on 19.08.2021.
//

import UIKit
import HealthKit

protocol Users {
    var userAge : String? { get }
    var userBlood : String? {get}
    var userSex : String?{get}
    var userHeight : String?{get}
    var userWeight : String?{get}
}

class User: Users {
    internal var userAge : String? = ""
    internal var userBlood : String? = ""
    internal var userSex : String? = ""
    internal var userHeight : String? = ""
    internal var userWeight : String? = ""

    let healthKitStore: HKHealthStore = HKHealthStore()
    let bodyMassType = HKSampleType.quantityType(forIdentifier: .bodyMass)!
    let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
    
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
    
    
    func readProfile(){
        self.userAge = readAge()
        self.userSex = readSex()
        self.userBlood = readBlood()
        readSample(sampleType: HKObjectType.quantityType(forIdentifier: .bodyMass)!)
        readSample(sampleType: HKObjectType.quantityType(forIdentifier: .height)!)
    }
    
    func readAge()->String?{
        var age:Int?
        do{
            let birthday = try healthKitStore.dateOfBirthComponents()
            let calendar = Calendar.current
            let currentyear = calendar.component(.year, from: Date())
            age = currentyear-birthday.year!
            let ages = "\((age ?? nil)!)"
            return ages
        }catch{
            return ""
        }
       
    }
    
    func readSex()->String?{
        var gender : String = ""
        do {
            let biologicalSex = try healthKitStore.biologicalSex() 
            switch biologicalSex.biologicalSex.rawValue{
            case 1:gender = "female"
            case 2:gender = "male"
            case 3:gender = "other"
            default:
                gender =  ""
                }
            }
            catch{
                gender = ""
                 }
       return gender

        }
    

 //generic func
    
    func readSample(sampleType:HKQuantityType){
        let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.last as? HKQuantitySample{
                if(sampleType == HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)){
                    self.userHeight = " \(result.quantity.doubleValue(for: HKUnit.meter()) )"
                }
                else if(sampleType == HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)){
                    self.userWeight = "\(result.quantity.doubleValue(for: HKUnit.gramUnit(with:.kilo)))"
                }
                
            }else{
                print("OOPS didnt get height \nResults => \(results), error => \(error)")
            }
        }
        self.healthKitStore.execute(query)

    }
    
    func readBlood()->String?{
        var blood : String = ""
        do {
            let bloodT = try healthKitStore.bloodType()
            switch (bloodT.bloodType) {
            case .aPositive: blood = "A+"
            case .aNegative: blood = "A-"
            case .bPositive: blood = "B+"
            case .bNegative: blood = "B-"
            case .abPositive: blood = "AB+"
            case .abNegative: blood = "AB-"
            case .oPositive: blood = "0+"
            case .oNegative: blood = "0-"
            default:
                blood = ""
                break
            }
        }
        catch{
            return ""
        }
        
        return blood
        
    }
    
   
    
    func checkAutorizationStatus(identifier : HKObjectType) -> Bool{
        
        let authorizationStatus = healthKitStore.authorizationStatus(for:identifier)
        if authorizationStatus == .notDetermined {
            print("Authorization Status not determined!")
            return false
        } else if authorizationStatus == .sharingDenied {
            print( "App doesn't have access to your \(identifier.identifier.description) data. You can enable access in the Settings application.")
               return false
        }
        else if authorizationStatus == .sharingAuthorized{
            return true
        }
        return false
    }
    
    
    func writeToKit(weightText : String? , heightText : String?){
        let today = NSDate()
        if checkAutorizationStatus(identifier: HKSampleType.quantityType(forIdentifier: .bodyMass)!){
            let weight = Double(weightText ?? "")

            if (weight != nil){
                if let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass){
                    let quantity = HKQuantity(unit:HKUnit.gram(),doubleValue:Double(weight!))
                    let sample = HKQuantitySample(type: type , quantity: quantity,start: today as Date,end: today as Date)
                    healthKitStore.save(sample) { (success, error) in
                        if success {
                            self.userWeight = weightText
                        }
                        print("Saved \(success),error \(error)")
                    }
                }
                
            }
        }
        
        if checkAutorizationStatus(identifier: HKSampleType.quantityType(forIdentifier: .height)!){
            let height = Double(heightText ?? "")
            if (height != nil){
                if let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height) {
                    let quantity = HKQuantity(unit: HKUnit.inch(), doubleValue: height!)
                    let sample = HKQuantitySample(type: type, quantity: quantity, start: today as Date, end: today as Date)
                    
                    self.healthKitStore.save(sample, withCompletion: { (success, error) in
                        if success {
                            self.userHeight = heightText
                        }
                    })
                }
                
            }
        }
        }
    
    func getUserSex()->String?{
        return self.userSex
    }
    func getUserBlood()->String?{
        return self.userBlood
    }
    func getUserAge()->String?{
        return self.userAge
    }
    func getUserWeight()->String?{
        return self.userWeight
    }
    func getUserHeight()->String?{
        return self.userHeight
    }
    
    
    
    //    func readWeight(){
    //        var weight : String = ""
    //        let query = HKSampleQuery(sampleType: bodyMassType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil)
    //        { (query, results, error) in
    //            if let result = results?.last as? HKQuantitySample {
    //                weight = "\(result.quantity.doubleValue(for: HKUnit.gramUnit(with:.kilo)))"
    //                self.userWeight = weight
    //            }
    //        }
    //        healthKitStore.execute(query)
    //
    //    }
    //
}


