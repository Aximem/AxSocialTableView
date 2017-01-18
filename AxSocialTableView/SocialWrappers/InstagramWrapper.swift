//
//  InstagramWrapper.swift
//  AxSocialTableView
//
//  Created by Maxime Charruel on 17/01/2017.
//  Copyright © 2017 Maxime Charruel. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public protocol InstagramWrapperDelegate {
    func syncInstagramFinished(instagramSocialObjects: [SocialObject])
}

open class InstagramWrapper {
    
    open var baseUrlString = ""
    open var screenName = ""
    
    open var delegate: InstagramWrapperDelegate?
    
    open var urlString: String? = ""
    open var maxPostId: String? = ""
    
    required public init(delegate: InstagramWrapperDelegate) {
        self.delegate = delegate
        
        // You must init this values in your specific class
        self.baseUrlString = ""
        self.screenName = ""
    }
    
    open func getInstagramPosts () {
        
        // WE DO NOT NEED TO GET ACCESS TOKEN WITH INSTAGRAM, JSON IS PUBLIC
        
        // Limit is 20 by default
        
        urlString = self.baseUrlString + screenName + "/media/"
        
        loadUrl(urlString: urlString!)
    }
    
    open func loadUrl (urlString: String) {
        
        let urlwithPercentEscapes = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        Alamofire.request(urlwithPercentEscapes!, method: .get)
            .responseJSON { response in
                let jsonObj = JSON(data: response.data!)
                if jsonObj != JSON.null  {
                    let items = jsonObj["items"]
                    if items != JSON.null {
                        self.syncInstagramTimeLine(instagramsJSONObject: items)
                    }
                }
        }
    }
    
    open func getNextInstagramPosts () {
        // This is not like twitter, url with max_id return insta with an ID less than (that is, older than) and NOT EQUAL !!!
        self.loadUrl(urlString: urlString! + "?max_id=" + self.maxPostId!)
    }
    
    open func syncInstagramTimeLine(instagramsJSONObject: JSON) {
        
        var instagramPostsArray: [SocialObject] = []
        
        for i in 0..<instagramsJSONObject.count {
            
            var socialImage: SocialImage?
            let imageJson = instagramsJSONObject[i]["images"]["standard_resolution"]
            if imageJson != JSON.null {
                let imageUrl = imageJson["url"].string!
                let width = imageJson["width"].int!
                let height = imageJson["height"].int!
                
                socialImage = SocialImage(url: imageUrl, width: width, height: height)
            }
            
            var textMessage: String = ""
            let messageJson = instagramsJSONObject[i]["caption"]["text"]
            if messageJson != JSON.null {
                textMessage = messageJson.string!
            }
            
            let postCreatedAtTimeStamp = instagramsJSONObject[i]["caption"]["created_time"].string!
            let publicationDate = NSDate(timeIntervalSince1970: TimeInterval(postCreatedAtTimeStamp)!)
            
            let socialObject = SocialObject.init(image: socialImage, text: textMessage, publicationDate: publicationDate, type: .instagram)
            
            instagramPostsArray.append(socialObject)
            
            if i == instagramsJSONObject.count-1 {
                // For last insta post, we get the id
                maxPostId = instagramsJSONObject[i]["id"].string!
            }
        }
        
        self.delegate?.syncInstagramFinished(instagramSocialObjects: instagramPostsArray)
    }
}
