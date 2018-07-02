//
//  LoginDataManager.swift
//  FacebookPOC
//
//  Created by Swapnil Dhotre on 10/12/17.
//  Copyright © 2017 Virag Brahme. All rights reserved.
//

import UIKit
import CoreData

class LoginDataManager: NSObject {

  static let sharedInstance = LoginDataManager()
  
  //MARK: Fetch Task
  func fetchUserInfoFromDB(completionHandler: @escaping (_ userData: UserModel, _ error: NSError?) -> Void) {
    
    //configure request
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    let userModel = UserModel()
    
    var dberror: NSError?
    
    //Fetch user data from DB
    CoreDataManager.sharedInstance.executeFetchRequest(fetchRequest) { (results, error) -> Void in
      let result = results as! [User]
      //print(result)
      if(result.count > 0){
        userModel.firstName = result.first?.firstname
        userModel.lastName = result.first?.lastname
        userModel.email = result.first?.email
        userModel.photoUrl = result.first?.photourl
        userModel.facebookId = result.first?.facebookid
      }
      dberror = error
      //Call completion handler
      completionHandler(userModel, dberror)
    }
    
  }
  
    
  //MARK: Fetch Task
  func fetchFriendsInfoFromDB(completionHandler: @escaping (_ userData: [UserModel], _ error: NSError?) -> Void) {
    
    var friendlist:[UserModel] = []
    //configure request
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "email == nil")
    
    var dberror: NSError?
    
    //Fetch user data from DB
    CoreDataManager.sharedInstance.executeFetchRequest(fetchRequest) { (results, error) -> Void in      
      for user in results as! [User] {
        let userModel = UserModel()
        userModel.firstName = user.firstname
        userModel.lastName = user.lastname
        userModel.email = user.email
        userModel.photoUrl = user.photourl
        userModel.facebookId = user.facebookid
        friendlist.append(userModel)
      }
      dberror = error
      //Call completion handler
      completionHandler(friendlist, dberror)
    }
  }
  
  //MARK: Save New Task
  func saveUserData(_ userModel:UserModel, failureHandler: @escaping (_ message: String?, _ error: NSError?) -> Void) {
    
    //Get entity object
    let userObject = User(context:CoreDataManager.sharedInstance.getContext())
    userObject.firstname = userModel.firstName
    userObject.lastname = userModel.lastName
    userObject.facebookid = userModel.facebookId
    userObject.email = userModel.email
    userObject.photourl = userModel.photoUrl
    
    //Fetch data from DB
    CoreDataManager.sharedInstance.save({ (error) -> Void in
      if error != nil {
        failureHandler(nil, error)
      }else{
        failureHandler("data saved successfully.", nil)
      }
    })
    
  }
  
    func getUserCount() -> Int {
        var count: Int = 0
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        do{
            count = try CoreDataManager.sharedInstance.getContext().count(for: fetchRequest)
        } catch {
            //Assert or handle exception gracefully
        }
        return count
    }
        
    func deleteAllUsersData() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        CoreDataManager.sharedInstance.executeDeleteRequest(fetchRequest) { (error)  in
            if error == nil {
                print("data deleted successfully")
            }
        }
    }
}
