//
//  FriendDetailsViewController.swift
//  FacebookPOC
//
//  Created by Swapnil Dhotre on 13/12/17.
//  Copyright © 2017 Virag Brahme. All rights reserved.
//

import UIKit

class FriendDetailsViewController: UIViewController {

  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var lblName: UILabel!
  
  var imageUrl: String?
  var name: String?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.initView()
      
      // Do any additional setup after loading the view.
      if let imageUrl = imageUrl, let name = name {
          self.imgView.loadImageUsingUrlString(urlString: imageUrl)
          self.lblName.text = name
        }
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func initView() {
    self.navigationItem.title = "Friend Details"
  }

}
