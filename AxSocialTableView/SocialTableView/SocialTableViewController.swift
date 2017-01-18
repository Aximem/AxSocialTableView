//
//  SocialTableViewController.swift
//  AxSocialTableView
//
//  Created by Maxime Charruel on 17/01/2017.
//  Copyright © 2017 Maxime Charruel. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SocialTableViewController: UIViewController, TwitterWrapperDelegate, FacebookWrapperDelegate, InstagramWrapperDelegate, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {
    
    @IBOutlet open weak var tableView: UITableView!

    let reuseIdentifierSocial = "SocialCell"
    
    var twitterWrapper: TwitterWrapper?
    var facebookWrapper: FacebookWrapper?
    var instagramWrapper: InstagramWrapper?
    
    var socialPostsArray = Set<SocialObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "SocialTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifierSocial)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        syncSocialNetworks()
    }

    func syncSocialNetworks () {
        // Sync twitter
        twitterWrapper = TwitterWrapper.init(delegate: self)
        
        //TEMP
        twitterWrapper?.baseUrlString = Constants.twitterBaseUrlString
        twitterWrapper?.consumerKey = Constants.twitterConsumerKey
        twitterWrapper?.consumerSecret = Constants.twitterConsumerSecret
        twitterWrapper?.screenName = Constants.twitterScreenName
        twitterWrapper?.pageSize = Constants.twitterPageSize
        
        twitterWrapper?.getTwitterPosts()
        
        // Sync Facebook
        facebookWrapper = FacebookWrapper.init(delegate: self)
        
        //TEMP
        facebookWrapper?.baseUrlString = Constants.facebookBaseUrlString
        facebookWrapper?.clientId = Constants.facebookClientId
        facebookWrapper?.clientSecret = Constants.facebookClientSecret
        facebookWrapper?.screenName = Constants.facebookScreenName
        facebookWrapper?.pageSize = Constants.facebookPageSize
        
        facebookWrapper?.getFacebookPosts()
        
        // Sync Instagram
        instagramWrapper = InstagramWrapper.init(delegate: self)
        
        // TEMP
        instagramWrapper?.baseUrlString = Constants.instagramBaseUrlString
        instagramWrapper?.screenName = Constants.instagramScreenName
        
        instagramWrapper?.getInstagramPosts()
    }
    
    // MARK: TwitterWrapperDelegate
    func syncTwitterFinished(twitterSocialObjects: [SocialObject]) {
        for twitterSocialObject in twitterSocialObjects {
            socialPostsArray.insert(twitterSocialObject)
        }
        self.tableView.reloadData()
    }
    
    // MARK: FacebookWrapperDelegate
    func syncFacebookFinished(facebookSocialObjects: [SocialObject]) {
        for facebookSocialObject in facebookSocialObjects {
            socialPostsArray.insert(facebookSocialObject)
        }
        self.tableView.reloadData()
    }
    
    // MARK: InstagramWrapperDelegate
    func syncInstagramFinished(instagramSocialObjects: [SocialObject]) {
        for instagramSocialObject in instagramSocialObjects {
            socialPostsArray.insert(instagramSocialObject)
        }
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return socialPostsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let socialObject: SocialObject = Array(socialPostsArray)[indexPath.row]
         
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierSocial, for: indexPath) as! SocialTableViewCell
        
        cell.dateLabel.text = Utils.timeAgoSinceDate(date: socialObject.publicationDate, numericDates: true)
        cell.socialTextLabel.text = socialObject.text
        addLabelHandler(label: cell.socialTextLabel)
        
        cell.socialImageView.image = getImageForSocialType(socialType: socialObject.type)
        
        if socialObject.image != nil {
            
            cell.imageHeightConstraint.constant = 175
            cell.postImageView.downloadedFrom(link: (socialObject.image?.url)!, contentMode: UIViewContentMode.scaleAspectFill)
        }
        else {
            cell.imageHeightConstraint.constant = 0
        }
        
        /*if indexPath.row == socialArray.count-4 && !lastItemReached {
            lastItemReached = true
            activityIndicatorView?.startAnimating()
            self.loadMoreSocialPosts()
        }*/
        /*if socialObject.image != nil {
         
         let height: CGFloat = cell.postImageView.frame.size.width * CGFloat((socialObject.image?.height)!) / CGFloat((socialObject.image?.width)!)
         
         //cell.postImageView.frame = CGRect(x: cell.postImageView.frame.origin.x, y: cell.postImageView.frame.origin.y, width: cell.postImageView.frame.size.width, height: height)
         
         //cell.postImageView.downloadedAndReloadTableViewFrom(link: (socialObject.image?.url)!, tableView: self.tableView, indexPath: indexPath)
         
         cell.postImageView.downloadedAndReloadTableViewFrom(link: (socialObject.image?.url)!, contentMode: UIViewContentMode.scaleAspectFit, tableView: self.tableView, indexPath: indexPath)
         
         // Resize image with maxWidth from cell.postImageView width
         cell.postImageView.image = cell.postImageView.image?.resizeImageWithWidth(newWidth: cell.postImageView.frame.size.width)
         
         if cell.postImageView.image != nil {
         // If image is not nil, we update postImageView frame
         cell.postImageView.frame = CGRect(x: cell.postImageView.frame.origin.x, y: cell.postImageView.frame.origin.y, width: (cell.postImageView.image?.size.width)!, height: (cell.postImageView.image?.size.height)!)
         }
         }*/
        /*if socialObject.imageUrls.count > 0 {
         // Method to load image from url and (when image is downloaded) reload tableview cell in order to update tableview cell height
         cell.postImageView.downloadedAndReloadTableViewFrom(link: socialObject.imageUrls[0], contentMode: UIViewContentMode.scaleAspectFill, tableView: self.tableView, indexPath: indexPath)
         // Resize image with maxWidth from cell.postImageView width
         cell.postImageView.image = cell.postImageView.image?.resizeImageWithWidth(newWidth: cell.postImageView.frame.size.width)
         if cell.postImageView.image != nil {
         // If image is not nil, we update postImageView frame
         cell.postImageView.frame = CGRect(x: cell.postImageView.frame.origin.x, y: cell.postImageView.frame.origin.y, width: (cell.postImageView.image?.size.width)!, height: (cell.postImageView.image?.size.height)!)
         }
         }
         else {
         cell.postImageView.image = UIImage()
         }*/
        
        return cell
    }
    
    open func getImageForSocialType (socialType: SocialType) -> UIImage {
        switch socialType {
        case .twitter:
            return UIImage.bundledImage(named: "twitter")!
        case .instagram:
            return UIImage.bundledImage(named: "instagram")!
        default: // .facebook
            return UIImage.bundledImage(named: "facebook")!
        }
    }
    
    open func addLabelHandler (label: KILabel) {
        
        label.userHandleLinkTapHandler = { label, handle, range in
            NSLog("User handle \(handle) tapped")
        }
        
        // Attach a block to be called when the user taps a hashtag
        label.hashtagLinkTapHandler = { label, hashtag, range in
            NSLog("Hashtah \(hashtag) tapped")
        }
        
        // Attach a block to be called when the user taps a URL
        label.urlLinkTapHandler = { label, url, range in
            NSLog("URL \(url) tapped")
            // Show intern webview
        }
    }
}
