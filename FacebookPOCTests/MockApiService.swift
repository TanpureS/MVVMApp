//
//  MockApiService.swift
//  FacebookPOCTests
//
//  Created by Shivaji Tanpure on 28/12/17.
//  Copyright © 2017 Virag Brahme. All rights reserved.
//

import UIKit
@testable import FacebookPOC

class MockApiService: APIServiceProtocol {
    
    var isFetchFriendsCalled = false
    var isFetchLoginDetailsCalled = false
    
    var completeFriends: [UserModel] = [UserModel]()
    var completeClosure: ((Bool, [UserModel]?, APIError?) -> ())!
    
    func fetchFriendList(complete: @escaping (Bool, [UserModel]?, APIError?) -> ()) {
        isFetchFriendsCalled = true
        completeClosure = complete
    }
    
    func fetchLoginUserData(complete: @escaping (Bool, UserModel?, APIError?) -> ()) {
    }
    func logOut(){
    }
    
    func fetchSuccess() {
        completeClosure( true, completeFriends, nil )
    }
    
    func fetchFail(error: APIError?) {
        completeClosure( false, completeFriends, error )
    }
    
}
