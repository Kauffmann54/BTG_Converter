//
//  CurrencyCoreData.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 16/01/21.
//

import Foundation
import UIKit
import CoreData

class CurrencyCoreData {
    // MARK: - Properties
    static let entityCurrency: String = "Currency"
    static let entityCurrencyLive: String = "CurrencyLive"
    static let entityCurrencySource: String = "CurrencySource"
    static let entityCurrencyDestiny: String = "CurrencyDestiny"
    
    // MARK: - Funtions
    
    /// Saves list currencies
    ///
    /// - Parameter currencyModel: list currency
    class func save(currencyModel: CurrencyModel, favorite: Bool) {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityCurrency)
        fetchRequest.predicate = NSPredicate(format: "currencyCode = %@", currencyModel.currencyCode)
        
        do {
            if let fetchResults = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count == 0 {
                    let entity = NSEntityDescription.entity(forEntityName: entityCurrency, in: managedContext)!
                  
                    let currency = NSManagedObject(entity: entity, insertInto: managedContext)
                  
                    currency.setValue(currencyModel.currencyName, forKeyPath: "currencyName")
                    currency.setValue(currencyModel.currencyCode, forKeyPath: "currencyCode")
                    currency.setValue(currencyModel.currencyFlag, forKeyPath: "currencyFlag")
                    currency.setValue(currencyModel.currencyValue, forKeyPath: "currencyValue")
                    currency.setValue(favorite, forKeyPath: "currencyFavorite")
                  
                  do {
                    try managedContext.save()
                  } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                  }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    /// Retrieves the currency list
    class func retrive(completion: @escaping ([NSManagedObject]) -> Void) {        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion([])
            return
        }
      
        let managedContext = appDelegate.persistentContainer.viewContext
      
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityCurrency)
      
        do {
            completion(try managedContext.fetch(fetchRequest))
        } catch let error as NSError {
            completion([])
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// Updates a currency from the currency list
    ///
    /// - Parameter currencyModel: list currency
    class func update(currencyModel: CurrencyModel, favorite: Bool) {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityCurrency)
        fetchRequest.predicate = NSPredicate(format: "currencyCode = %@", currencyModel.currencyCode)
        
        do {
            if let fetchResults = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0 {
                    let currency = fetchResults[0]
                  
                    currency.setValue(currencyModel.currencyName, forKeyPath: "currencyName")
                    currency.setValue(currencyModel.currencyCode, forKeyPath: "currencyCode")
                    currency.setValue(currencyModel.currencyFlag, forKeyPath: "currencyFlag")
                    currency.setValue(currencyModel.currencyValue, forKeyPath: "currencyValue")
                    currency.setValue(favorite, forKeyPath: "currencyFavorite")
                  do {
                    try managedContext.save()
                  } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                  }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// Deletes a currency from the list
    ///
    /// - Parameter currencyModel: list currency
    class func delete(currencyModel: CurrencyModel) {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityCurrency)
        fetchRequest.predicate = NSPredicate(format: "currencyCode = %@", currencyModel.currencyCode)
        
        do {
            if let fetchResults = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0 {
                    for object in fetchResults {
                        managedContext.delete(object)
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// Saves the current quote or updates, if already saved locally
    ///
    /// - Parameter currencyValueModel: current quote
    class func saveLive(currencyValueModel: CurrencyValueModel) {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityCurrencyLive)
        
        do {
            if let fetchResults = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0 {
                    let currency = fetchResults[0]
                  
                    currency.setValue(currencyValueModel.quotes, forKeyPath: "quotes")
                    currency.setValue(currencyValueModel.privacy, forKeyPath: "privacy")
                    currency.setValue(currencyValueModel.source, forKeyPath: "source")
                    currency.setValue(currencyValueModel.success, forKeyPath: "success")
                    currency.setValue(currencyValueModel.terms, forKeyPath: "terms")
                    currency.setValue(currencyValueModel.timestamp, forKeyPath: "timestamp")
                  do {
                    try managedContext.save()
                  } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                  }
                } else {
                    let entity = NSEntityDescription.entity(forEntityName: entityCurrencyLive, in: managedContext)!
                  
                    let currency = NSManagedObject(entity: entity, insertInto: managedContext)
                  
                    currency.setValue(currencyValueModel.quotes, forKeyPath: "quotes")
                    currency.setValue(currencyValueModel.privacy, forKeyPath: "privacy")
                    currency.setValue(currencyValueModel.source, forKeyPath: "source")
                    currency.setValue(currencyValueModel.success, forKeyPath: "success")
                    currency.setValue(currencyValueModel.terms, forKeyPath: "terms")
                    currency.setValue(currencyValueModel.timestamp, forKeyPath: "timestamp")
                  
                  do {
                    try managedContext.save()
                  } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                  }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// Retrieves the current quote
    class func retriveLive(completion: @escaping (NSManagedObject?) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(nil)
            return
        }
      
        let managedContext = appDelegate.persistentContainer.viewContext
      
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityCurrencyLive)
      
        do {
            completion(try managedContext.fetch(fetchRequest).first)
        } catch let error as NSError {
            completion(nil)
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// Save source currency
    ///
    /// - Parameter currencyModel: selected source currency
    class func saveCurrencySource(currencyModel: CurrencyModel) {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityCurrencySource)
        
        do {
            if let fetchResults = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0 {
                    let currency = fetchResults[0]
                  
                    currency.setValue(currencyModel.currencyCode, forKeyPath: "currencyCode")
                    currency.setValue(currencyModel.currencyFlag, forKeyPath: "currencyFlag")
                    currency.setValue(currencyModel.currencyName, forKeyPath: "currencyName")
                    currency.setValue(currencyModel.currencyValue, forKeyPath: "currencyValue")
                  do {
                    try managedContext.save()
                  } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                  }
                } else {
                    let entity = NSEntityDescription.entity(forEntityName: entityCurrencySource, in: managedContext)!
                  
                    let currency = NSManagedObject(entity: entity, insertInto: managedContext)
                  
                    currency.setValue(currencyModel.currencyCode, forKeyPath: "currencyCode")
                    currency.setValue(currencyModel.currencyFlag, forKeyPath: "currencyFlag")
                    currency.setValue(currencyModel.currencyName, forKeyPath: "currencyName")
                    currency.setValue(currencyModel.currencyValue, forKeyPath: "currencyValue")
                  
                  do {
                    try managedContext.save()
                  } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                  }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// Save source destiny
    ///
    /// - Parameter currencyModel: selected destiny currency
    class func saveCurrencyDestiny(currencyModel: CurrencyModel) {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }

        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityCurrencyDestiny)
        
        do {
            if let fetchResults = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0 {
                    let currency = fetchResults[0]
                  
                    currency.setValue(currencyModel.currencyCode, forKeyPath: "currencyCode")
                    currency.setValue(currencyModel.currencyFlag, forKeyPath: "currencyFlag")
                    currency.setValue(currencyModel.currencyName, forKeyPath: "currencyName")
                    currency.setValue(currencyModel.currencyValue, forKeyPath: "currencyValue")
                  do {
                    try managedContext.save()
                  } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                  }
                } else {
                    let entity = NSEntityDescription.entity(forEntityName: entityCurrencyDestiny, in: managedContext)!
                  
                    let currency = NSManagedObject(entity: entity, insertInto: managedContext)
                  
                    currency.setValue(currencyModel.currencyCode, forKeyPath: "currencyCode")
                    currency.setValue(currencyModel.currencyFlag, forKeyPath: "currencyFlag")
                    currency.setValue(currencyModel.currencyName, forKeyPath: "currencyName")
                    currency.setValue(currencyModel.currencyValue, forKeyPath: "currencyValue")
                  
                  do {
                    try managedContext.save()
                  } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                  }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// Retrieves selected source currency
    class func retriveCurrencySource(completion: @escaping (NSManagedObject?) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(nil)
            return
        }
      
        let managedContext = appDelegate.persistentContainer.viewContext
      
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityCurrencySource)
      
        do {
            completion(try managedContext.fetch(fetchRequest).first)
        } catch let error as NSError {
            completion(nil)
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// Retrieves selected source destiny
    class func retriveCurrencyDestiny(completion: @escaping (NSManagedObject?) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(nil)
            return
        }
      
        let managedContext = appDelegate.persistentContainer.viewContext
      
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityCurrencyDestiny)
      
        do {
            completion(try managedContext.fetch(fetchRequest).first)
        } catch let error as NSError {
            completion(nil)
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}


