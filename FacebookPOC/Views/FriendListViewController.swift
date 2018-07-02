//
//  FriendListViewController.swift
//  FacebookPOC
//
//  Created by Shivaji Tanpure on 04/12/17.
//  Copyright © 2017 Shivaji Tanpure. All rights reserved.
//

import UIKit
import MBProgressHUD

class FriendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var lblMessageNoRecords: UILabel!
    
  lazy var viewModel: FriendListViewModel = {
    return FriendListViewModel()
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    // Init the static view
    initView()
    
    // init view model
    initVM()
    
  }
  
  func initView() {
    self.navigationItem.title = "Friend List"
    lblMessageNoRecords.text = kNoRecordsFound
    self.lblMessageNoRecords.isHidden = true
  }
  
  func initVM() {
    
    // Naive binding
    viewModel.showAlertClosure = { [weak self] () in
      DispatchQueue.main.async {
        if let message = self?.viewModel.alertMessage {
          self?.showAlert( message )
        }
      }
    }
    
    viewModel.updateLoadingStatus = { [weak self] () in
      DispatchQueue.main.async {
        let isLoading = self?.viewModel.isLoading ?? false
        if isLoading {
          self?.showLoadingHUD()
          UIView.animate(withDuration: 0.2, animations: {
            self?.tableView.alpha = 0.0
          })
        }else {
          self?.hideLoadingHUD()
          UIView.animate(withDuration: 0.2, animations: {
            self?.tableView.alpha = 1.0
          })
        }
      }
    }
    
    viewModel.reloadTableViewClosure = { [weak self] () in
      DispatchQueue.main.async {
        //Reload data on main thread
        if(self?.viewModel.friends.count == 0){
            self?.tableView.isHidden = true
            self?.lblMessageNoRecords.isHidden = false
        }else{
            self?.lblMessageNoRecords.isHidden = true
            self?.tableView.reloadData()
        }
      }
    }
    
    //fetch friend list
    viewModel.initGetFriends()
    
  }
  
  func showAlert( _ message: String ) {
    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
    alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
    
  // MARK: - MBProgressHUD Methods
  func showLoadingHUD() {
    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
    hud.label.text = "Loading..."
  }
  func hideLoadingHUD() {
    MBProgressHUD.hide(for: self.view, animated: true)
  }
  
  // MARK: - TableView Delegate
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath) as? FriendListCell else {
      fatalError("Cell not exists in storyboard")
    }
    
    let cellVM = viewModel.getCellViewModel(at: indexPath)
    cell.configureCellWithData(friend: cellVM)
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 65.0
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfCells
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    self.viewModel.userPressed(at: indexPath)
    if viewModel.isAllowSegue {
      return indexPath
    }else {
      return nil
    }
  }
  
  // MARK: - Segue Delegate Method
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? FriendDetailsViewController,
      let friend = self.viewModel.selectedFriend {
      vc.imageUrl = friend.photoUrl
      vc.name = friend.fullName
    }
  }
  
}
