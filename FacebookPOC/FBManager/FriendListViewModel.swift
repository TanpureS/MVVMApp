//
//  FriendListViewModel.swift
//  FacebookPOC
//
//  Created by Swapnil Dhotre on 11/12/17.
//  Copyright © 2017 Virag Brahme. All rights reserved.
//

import UIKit

struct FriendListCellViewModel {
  let name: String
  let imageUrl: String
}

class FriendListViewModel {
  
  let apiService: APIServiceProtocol
  
  var friends: [UserModel] = [UserModel]()
  var name:String = ""
  var imageUrl:String = ""

  private var cellViewModels: [FriendListCellViewModel] = [FriendListCellViewModel]() {
    didSet {
      self.reloadTableViewClosure?()
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
  
  var numberOfCells: Int {
    return cellViewModels.count
  }
  
  var isAllowSegue: Bool = false
  var selectedFriend: UserModel?
  
  var reloadTableViewClosure: (()->())?
  var showAlertClosure: (()->())?
  var updateLoadingStatus: (()->())?
  
  init( apiService: APIServiceProtocol = FacebookLoginManager()) {
    self.apiService = apiService
  }
  
  func initGetFriends() {
    self.isLoading = true
    apiService.fetchFriendList { [weak self] (success, firends, error) in
      self?.isLoading = false
      if let error = error {
        self?.alertMessage = error.rawValue
      } else {
        self?.processFetchedFriends(friends: firends!)
      }
    }
  }
  
  func getCellViewModel( at indexPath: IndexPath ) -> FriendListCellViewModel {
    return cellViewModels[indexPath.row]
  }
  
  func createCellViewModel( user: UserModel ) -> FriendListCellViewModel {
    
    //Wrap a description
    
    if let firstname = user.firstName,let lastname = user.lastName ,let imageurl = user.photoUrl {
      self.name = "\(firstname) \(lastname)"
      self.imageUrl = imageurl
    }else{
      print("Error")
    }
    return FriendListCellViewModel(name: self.name,
                                   imageUrl: self.imageUrl)
  }
  
  private func processFetchedFriends(friends:[UserModel]) {
    self.friends = friends // Cache
    var vms = [FriendListCellViewModel]()
    for firend in friends {
      vms.append( createCellViewModel(user: firend) )
    }
    self.cellViewModels = vms
  }
  
  func userPressed( at indexPath: IndexPath ){
    let friend = self.friends[indexPath.row]
    if let firstname = friend.firstName,let lastname = friend.lastName ,let imageurl = friend.photoUrl {
      self.isAllowSegue = true
      friend.fullName = "\(firstname) \(lastname)"
      friend.photoUrl = imageurl
      self.selectedFriend = friend
    }
  
  }
  
}



