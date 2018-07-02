//
//  LoginParser.swift
//  FacebookPOC
//
//  Created by Swapnil Dhotre on 10/12/17.
//  Copyright © 2017 Virag Brahme. All rights reserved.
//

import UIKit

class LoginParser: NSObject {
  
  func parseLoginData(dict:NSDictionary,completion: @escaping (_ data:UserModel) -> Void){
    
    let model = UserModel()
    model.firstName = dict["first_name"] as? String
    model.lastName = dict["last_name"] as? String
    model.facebookId = dict["id"] as! String
    model.email = dict["email"] as? String
    let imgdictionary = dict["picture"] as? NSDictionary
    let data = imgdictionary?["data"] as? NSDictionary
    let imageurl = data?["url"]
    model.photoUrl = imageurl as? String
    //Save user data into DB
    self.saveUserDataIntoDB(userModel: model)
    completion(model)

  }
  
  func parseFriendListData(dict:NSDictionary,completion: @escaping (_ data:[UserModel]) -> Void){
    var friendsArray:[UserModel] = []
    if(dict["data"] != nil){
      for item in dict["data"] as! NSArray{
        let itemdict = item as! NSDictionary
        //print("Item::\(item)")
        let model = UserModel()
        model.firstName = itemdict["first_name"] as? String
        model.lastName = itemdict["last_name"] as? String
        model.facebookId = itemdict["id"] as! String
        model.fullName = itemdict["name"] as? String
        let imgdictionary = itemdict["picture"] as? NSDictionary
        let data = imgdictionary?["data"] as? NSDictionary
        let imageurl = data?["url"]
        model.photoUrl = imageurl as? String
        self.saveUserDataIntoDB(userModel: model)
        friendsArray.append(model)
      }
    }
    completion(friendsArray)
  }
  
  func saveUserDataIntoDB(userModel:UserModel){
    //Save user data into DB
    LoginDataManager.sharedInstance.saveUserData(userModel) { (callbackMessage, error) -> Void in
      if error != nil {
        print("Error:\(String(describing: error))")
      }else {
        print("Message:\(callbackMessage!)")
      }
    }
  }
  
}
