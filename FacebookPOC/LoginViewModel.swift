//
//  LoginViewModel.swift
//  FacebookPOC
//
//  Created by Swapnil Dhotre on 10/12/17.
//  Copyright © 2017 Virag Brahme. All rights reserved.
//

import UIKit

class LoginViewModel {
  
  let apiService: APIServiceProtocol
  
  var name:String = ""
  var imageUrl:String = ""
  
  private var user: UserModel = UserModel(){
    didSet {
      self.reloadLoginViewClosure?()
    }
  }
  
  var isLoading: Bool = false {
    didSet {
      self.updateLoadingStatus?()
    }
  }
  
  var alertMessage: String? {
    didSet {
      self.showAlertClosure?()
    }
  }  
  
  var reloadLoginViewClosure: (()->())?
  var showAlertClosure: (()->())?
  var updateLoadingStatus: (()->())?
  
  init( apiService: APIServiceProtocol = FacebookLoginManager()) {
    self.apiService = apiService
  }
  
  func initGetLoggedInUserDetails() {
    self.isLoading = true
    apiService.fetchLoginUserData(complete:{ [weak self] (success, user, error) in
      self?.isLoading = false
      if let error = error {
        self?.alertMessage = error.rawValue
      } else {
        self?.processFetchedFriends(userdata: user!)
      }
    })
  }
  
  private func processFetchedFriends(userdata:UserModel) {
    //Wrap a description
    if let firstname = userdata.firstName,let lastname = userdata.lastName ,let imageurl = userdata.photoUrl {
      self.name = "\(firstname) \(lastname)"
      self.imageUrl = imageurl
    }else{
      print("Error")
    }   
    //update user model
    self.user = userdata
  }
  
  func signOutWithFacebook() {
    apiService.logOut()
  }

}
