//
//  FriendListCell.swift
//  FacebookPOC
//
//  Created by Shivaji Tanpure on 11/12/17.
//  Copyright © 2017 Virag Brahme. All rights reserved.
//

import UIKit

class FriendListCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellWithData(friend:FriendListCellViewModel){
        self.imageView?.loadImageUsingUrlString(urlString: friend.imageUrl)
        self.lblName.text = friend.name
    }

}
