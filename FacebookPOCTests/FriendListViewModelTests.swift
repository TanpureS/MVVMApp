//
//  FriendListViewModelTests.swift
//  FacebookPOCTests
//
//  Created by Shivaji Tanpure on 20/12/17.
//  Copyright © 2017 Virag Brahme. All rights reserved.
//

import XCTest
@testable import FacebookPOC

class FriendListViewModelTests: XCTestCase {
    var sut: FriendListViewModel!
    var mockAPIService: MockApiService!

    override func setUp() {
        super.setUp()
        mockAPIService = MockApiService()
        sut = FriendListViewModel(apiService: mockAPIService)
    }
    
    override func tearDown() {
        sut = nil
        mockAPIService = nil
        super.tearDown()
    }
  
    func test_fetch_friends() {
      // Given
      mockAPIService.completeFriends = [UserModel]()
    
      // When
      sut.initGetFriends()
    
      // Assert
      XCTAssert(mockAPIService!.isFetchFriendsCalled)
    }
  
  func test_fetch_friends_fail() {
    
    // Given a failed fetch with a certain failure
    let error = APIError.permissionDenied
    
    // When
    sut.initGetFriends()

    mockAPIService.fetchFail(error: error )
    
    // Sut should display predefined error message
    XCTAssertEqual(sut.alertMessage, error.rawValue )
    
  }
  
  func test_create_cell_view_model() {
    // Given
    let friends = StubGenerator().stubFriends()
    mockAPIService.completeFriends = friends
    let expect = XCTestExpectation(description: "reload closure triggered")
    sut.reloadTableViewClosure = { () in
      expect.fulfill()
    }
    
    // When
    sut.initGetFriends()
    mockAPIService.fetchSuccess()
    
    // Number of cell view model is equal to the number of friends
    XCTAssertEqual(sut.numberOfCells, friends.count )
    
    // XCTAssert reload closure triggered
    wait(for: [expect], timeout: 2.0)
    
  }
  
  func test_loading_when_fetching() {
    //Given
    var loadingStatus = false
    let expect = XCTestExpectation(description: "Loading status updated")
    sut.updateLoadingStatus = { [weak sut] in
      loadingStatus = sut!.isLoading
      expect.fulfill()
    }
    
    //when fetching
    sut.initGetFriends()

    // Assert
    XCTAssertTrue( loadingStatus )
    
    // When finished fetching
    mockAPIService!.fetchSuccess()
    XCTAssertFalse( loadingStatus )
    
    wait(for: [expect], timeout: 2.0)
  }
  
  func test_user_press_for_row_item() {
    
    //Given a sut with fetched friends
    let indexPath = IndexPath(row: 0, section: 0)
    goToFetchFriendsFinished()
    
    //When
    sut.userPressed( at: indexPath )
    
    //Assert
    XCTAssertTrue( sut.isAllowSegue )
    XCTAssertNotNil( sut.selectedFriend )
    
  }
  
  func test_cell_view_model() {
    //Given photos
    let friend = UserModel()
    friend.firstName = "Rohit"
    friend.lastName = "Shinde"
    friend.facebookId = "230200335"
    friend.photoUrl = "https://pacdn.500px.org/5797936/de2fb89866d28abafb02158e01d9195dead71c94/1.jpg?20"

    // When creat cell view model
    let cellViewModel = sut!.createCellViewModel(user: friend)
   
    // Assert the correctness of display information
    XCTAssertEqual(cellViewModel.name, "\(friend.firstName!) \(friend.lastName!)" )
    XCTAssertEqual( friend.photoUrl, cellViewModel.imageUrl )
  }
  
}


//MARK: State control
extension FriendListViewModelTests {
  fileprivate func goToFetchFriendsFinished() {
    mockAPIService.completeFriends = StubGenerator().stubFriends()
    sut.initGetFriends()
    mockAPIService.fetchSuccess()
  }
}


class StubGenerator {
  func stubFriends() -> [UserModel] {
    
    var friendList:[UserModel] = []
    
    let path = Bundle.main.path(forResource: "content", ofType: "json")!
    let data = try! Data(contentsOf: URL(fileURLWithPath: path))
    let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
    
    for item in jsonData!["friends"] as! NSArray{
        let itemdict = item as! NSDictionary
        let model = UserModel()
        model.firstName = itemdict["first_name"] as? String
        model.lastName = itemdict["last_name"] as? String
        model.facebookId = String(describing: itemdict["id"] as! NSNumber)
        model.photoUrl = itemdict["imageurl"] as? String
        friendList.append(model)
    }
    return friendList
  }
}


