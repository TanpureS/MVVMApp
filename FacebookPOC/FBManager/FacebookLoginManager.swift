//
//  FacebookLoginManager.swift
//  FacebookPOC
//
//  Created by Shivaji Tanpure on 08/12/17.
//  Copyright © 2017 Virag Brahme. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

enum APIError: String, Error {
  case noNetwork = "No Network"
  case serverOverload = "Server is overloaded"
  case permissionDenied = "You don't have permission"
  case dbError = "Error while fetching data"

}

protocol APIServiceProtocol {
  func fetchLoginUserData( complete: @escaping ( _ success: Bool, _ user: UserModel?, _ error: APIError? )->() )
  
  func fetchFriendList( complete: @escaping ( _ success: Bool, _ friends: [UserModel]?, _ error: APIError? )->() )
  
  func logOut()
}


class FacebookLoginManager: NSObject,APIServiceProtocol {
  
    let fbLoginManager = FBSDKLoginManager()
    
    var viewController : UIViewController?
  
    var userInfo : NSDictionary = NSDictionary()
  
    var friendsInfo : NSDictionary = NSDictionary()

    let loginParser = LoginParser()
  
  
  //Marks: Fb Keys
  let Fb_Email = "email"
  let Fb_First_Name = "first_name"
  let Fb_Last_Name = "last_name"
  let Fb_Application_Id = "ApplicationId"
  let Fb_Expires = "Expires"
  let Fb_Token = "Token"
  let Fb_User_Id = "UserId"
  
  
  //MARK: Get User Info From Graph Method
  //get fb user data from graph api
  func fetchLoginUserData( complete: @escaping ( _ success: Bool, _ user: UserModel?, _ error: APIError? )->() ) {
    //Get user count from entity
    let count: Int = LoginDataManager.sharedInstance.getUserCount()
    print("Count = \(count)")
    if(count == 0){
      
    //Fetch data from API
    if((FBSDKAccessToken.current()) != nil){
      //print("AccessToken - \(FBSDKAccessToken.current().tokenString)")
      FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name,picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
        if (error == nil){
          
          self.userInfo = result as! NSDictionary
          //print(self.userInfo)
          
          //Parse user info
          self.loginParser.parseLoginData(dict: self.userInfo,
                                          completion:{ (userData:UserModel) in
              complete( true, userData, nil )
          });
          
        }else if(error != nil){
          print("Error:\(String(describing: error?.localizedDescription))")
          complete( true, nil, APIError.permissionDenied )
        }
        
      })
    }
      
    }else{
      //Fetch data from local DB
      LoginDataManager.sharedInstance.fetchUserInfoFromDB { (userModel, error) in
        if (error == nil){
          complete( true, userModel, nil )
        }else if(error != nil){
          print("Error:\(String(describing: error?.localizedDescription))")
            complete( true, nil, APIError.dbError )
        }
      
      }

    }
    
  }
  
  
func fetchFriendList( complete: @escaping ( _ success: Bool, _ friends: [UserModel]?, _ error: APIError? )->() ) {
    
    //Get user count from entity
    let count: Int = LoginDataManager.sharedInstance.getUserCount()
    if(count == 1){
  
    //Fetch data from API
    if((FBSDKAccessToken.current()) != nil){
      
      //Get friendlist
      let params = ["fields": "id, first_name, last_name, name, location, picture.height(100).width(100)"]
      if((FBSDKAccessToken.current()) != nil){
        FBSDKGraphRequest(graphPath: "me/taggable_friends?limit=5000", parameters: params).start(completionHandler:
        { (connection, result, error) -> Void in
          if (error == nil){
            self.friendsInfo = result as! NSDictionary
            //print(self.friendsInfo)
            self.loginParser.parseFriendListData(dict: self.friendsInfo,
                                            completion:{ (friendsList:[UserModel]) in
                                              
              print("Total :: \(friendsList.count)")
              //completion(friendsList)
              complete( true, friendsList, nil )
                                              
            });
            
          }else if(error != nil){
            print("Error:\(String(describing: error?.localizedDescription))")
            complete( true, nil, APIError.permissionDenied )
          }
        })
      }
      
    }
      
    }else{
      //Fetch data from local DB
      LoginDataManager.sharedInstance.fetchFriendsInfoFromDB(completionHandler: {(friendlist, error) in
        if (error == nil){
          print("Total DB Record:: \(friendlist.count)")
          complete( true, friendlist, nil )
        }else if(error != nil){
          print("Error:\(String(describing: error?.localizedDescription))")
            complete( true, nil, APIError.dbError )
        }
        
      })
    }
    
  }

  func logOut(){
    fbLoginManager.logOut()
    LoginDataManager.sharedInstance.deleteAllUsersData()
  }
  

}
