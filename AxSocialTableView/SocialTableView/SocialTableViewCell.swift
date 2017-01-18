//
//  SocialTableViewCell.swift
//  AxSocialTableView
//
//  Created by Maxime Charruel on 17/01/2017.
//  Copyright © 2017 Maxime Charruel. All rights reserved.
//

import UIKit

class SocialTableViewCell: UITableViewCell {

    @IBOutlet weak var socialTextLabel: KILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var socialImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postImageView.clipsToBounds = true
    }
}
