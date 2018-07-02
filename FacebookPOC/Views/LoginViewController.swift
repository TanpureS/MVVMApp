//
//  LoginViewController.swift
//  FacebookPOC
//
//  Created by Shivaji Tanpure on 03/12/17.
//  Copyright © 2017 Shivaji Tanpure. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import MBProgressHUD


class LoginViewController: UIViewController,FBSDKLoginButtonDelegate {

    @IBOutlet weak var lblLoginStatus: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var userPictureImgView: UIImageView!
    @IBOutlet weak var btnViewFriends: UIButton!
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!

    lazy var viewModel: LoginViewModel = {
      return LoginViewModel()
    }()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      // Init the static view
      initView()
      
    
      //Set read permission
      fbLoginButton.readPermissions = [kPublicProfile,kEmail,kUserFriends]
      fbLoginButton.delegate = self;
      
      //Register notification to observe token changes
      FBSDKProfile.enableUpdates(onAccessTokenChange: true)
      NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.onProfileUpdated(_:)), name:NSNotification.Name.FBSDKProfileDidChange, object: nil)
 
      //if the user has already logged in
      if FBSDKAccessToken.current() != nil {
        if(AppUtility.sharedInstance.isInternetAvailable()){
          // init view model
          initVM()
        }
      }
        
        returnUserData()
           
  }
  
  
  func initView() {
    self.navigationItem.title = "Profile Info"
    //Hide labels
    self.hideUserInfo(shouldHide: true)
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
        }else {
          self?.hideLoadingHUD()
        }
      }
    }
    
    viewModel.reloadLoginViewClosure = { [weak self] () in
      DispatchQueue.main.async {
        self?.showUserDetails()
      }
    }
    
    //fetch logged in user details
    viewModel.initGetLoggedInUserDetails()
    
  }

  func showAlert( _ message: String ) {
    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
    alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  //MARK: Private Method
  func hideUserInfo(shouldHide:Bool){
        //Hide labels
        lblLoginStatus.isHidden = shouldHide
        lblUserName.isHidden = shouldHide
        userPictureImgView.isHidden = shouldHide
        btnViewFriends.isHidden = shouldHide
    }
  
  //show user details
  func showUserDetails(){
    self.userPictureImgView.loadImageUsingUrlString(urlString: self.viewModel.imageUrl)
    self.lblUserName.text = self.viewModel.name
    self.lblLoginStatus.text = kLoggedInMessage
    self.hideUserInfo(shouldHide: false)
    
  }
  
    // MARK: - MBProgressHUD Methods
    func showLoadingHUD() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Loging..."
    }
    func hideLoadingHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
  
  // MARK: - FBSDKLoginButtonDelegate Methods
  public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!){
    
    if ((error) != nil) {
      // Process error
      print("facebook login error :: \(error.localizedDescription)")
      self.showAlert(error.localizedDescription)
    }
    else if result.isCancelled {
      self.showAlert(kLoginCancelled)
      // Handle cancellations
      //print("facebook login cancelled.")
    }
    else {
      // Navigate to other view
      //print("facebook login success.")
   
      if FBSDKAccessToken.current() != nil {
        // init view model
        initVM()
      }

    }
  }
  public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!){
    //print("logged out")
    if(AppUtility.sharedInstance.isInternetAvailable()){
      self.viewModel.signOutWithFacebook()
      self.hideUserInfo(shouldHide: true)
    }
  }
  
  // MARK: - Notification Methods
  func onProfileUpdated(_ notification: Notification) {
    
    //print("Profile updated.")
    if FBSDKAccessToken.current() != nil{
      //let name = FBSDKProfile.current().name
      //print("logged user name:\(name!)")
      
    }else{
      //print("logged out")
      if(AppUtility.sharedInstance.isInternetAvailable()){
        self.viewModel.signOutWithFacebook()
        self.hideUserInfo(shouldHide: true)
      }
    }
    
  }
  
  // MARK: - Action Methods
  @IBAction func facebookLoginTapped(_ sender: Any) {
    if(!AppUtility.sharedInstance.isInternetAvailable()){
      self.showAlert(kNoNetworkMessage)
      return
    }
  }
  
  @IBAction func viewFriends(_ sender: Any) {
    if(!AppUtility.sharedInstance.isInternetAvailable()){
      self.showAlert(kNoNetworkMessage)
      return
    }
  }
  
  // MARK: - Segue Delegate Method
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if(!AppUtility.sharedInstance.isInternetAvailable()){
      self.showAlert(kNoNetworkMessage)
      return
    }
  }
    
    func returnUserData()
    {
        
        
        let params = ["fields": "id, name"]
        FBSDKGraphRequest(graphPath: "me/friends", parameters: params).start { (connection, result , error) -> Void in
            
            if error != nil {
                print(error!)
            }
            else {
                print("Result:\(result!)")
                //Do further work with response
            }
        }
        
        
       
        
    }
    
    
  
}



