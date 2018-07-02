//
//  CoreDataManager.swift
//  FacebookPOC
//
//  Created by Cuelogic on 05/12/17.
//  Copyright © 2017 Virag Brahme. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    static let sharedInstance = CoreDataManager()
    private override init() {}

    // MARK: - Core Data stack
    func getContext () -> NSManagedObjectContext {
        return CoreDataManager.sharedInstance.persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FacebookPOC")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Fetches
    func executeFetchRequest<T>(_ request:NSFetchRequest<T>,completionHandler:(_ results: Array<AnyObject>?, _ error: NSError?) -> Void)-> () {
        
        let context = persistentContainer.viewContext
        
        var fetchError:NSError?
        var results:Array<AnyObject>?
        do {
            results = try context.fetch(request)
        } catch let error as NSError {
            fetchError = error
            results = nil
        }
        if let error = fetchError {
            print("Warning!! \(error.description)")
        }
        completionHandler(results as Array<AnyObject>?, fetchError)
    }
    
    // MARK: - Delete Object
    func executeDeleteRequest<T>(_ request:NSFetchRequest<T>,failureHandler:(_ error: NSError?) -> Void)-> () {
        let context = persistentContainer.viewContext
        let deleteRequest = NSBatchDeleteRequest(fetchRequest:(request as! NSFetchRequest<NSFetchRequestResult>))
        do {
            try context.execute(deleteRequest)
        } catch {
            print ("There was an error")
        }
        self.save { (error) -> Void in
            if error != nil {
                failureHandler(error)
            }else{
                failureHandler(nil)
           }
    
        }
    }
    
    //MARK: - Save Methods
    func save(_ failureHandler:(_ error: NSError?) -> Void) {
        
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                failureHandler(nil)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                failureHandler(nserror)
            }
        }
        
    }
    
}

