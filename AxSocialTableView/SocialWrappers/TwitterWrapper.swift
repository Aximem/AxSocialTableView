//
//  TwitterWrapper.swift
//  AxSocialTableView
//
//  Created by Maxime Charruel on 17/01/2017.
//  Copyright © 2017 Maxime Charruel. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public protocol TwitterWrapperDelegate {
    func syncTwitterFinished(twitterSocialObjects: [SocialObject])
}

open class TwitterWrapper {
    
    open var accessToken: String?
    
    open var consumerKey = ""
    open var consumerSecret = ""
    open var baseUrlString = ""
    open var pageSize = 20
    open var screenName = ""
    
    open var delegate: TwitterWrapperDelegate?
    
    open var maxPostId: String? = ""
    
    required public init(delegate: TwitterWrapperDelegate) {
        self.delegate = delegate
        
        // You must init property values in your specific class
        self.consumerKey = ""
        self.consumerSecret = ""
        self.baseUrlString = ""
        self.pageSize = 20
        self.screenName = ""
    }
    
    open func authenticate(completionBlock: @escaping (Void) -> ()) {
        
        if accessToken != nil {
            completionBlock()
        }
        
        let credentials = "\(consumerKey):\(consumerSecret)"
        let headers = ["Authorization": "Basic \(credentials.getBase64())"]
        let params: [String : AnyObject] = ["grant_type": "client_credentials" as AnyObject]
        
        Alamofire.request("https://api.twitter.com/oauth2/token", method: .post, parameters: params, headers: headers)
            .responseJSON { response in
                let jsonObj = JSON(data: response.data!)
                if jsonObj != JSON.null  {
                    self.accessToken = jsonObj["access_token"].string
                    completionBlock()
                }
        }
    }
    
    open func getTwitterPosts () {
        
        authenticate {
            
            guard let token = self.accessToken else {
                // TODO: Show authentication error
                return
            }
            
            let headers = ["Authorization": "Bearer \(token)"]
            let params: [String : AnyObject] = [
                "screen_name" : self.screenName as AnyObject,
                "count": self.pageSize as AnyObject
            ]
            
            self.loadUrl(urlString: self.baseUrlString + "statuses/user_timeline.json", params: params, headers: headers, firstLaunch: true)
        }
    }
    
    open func loadUrl (urlString: String, params: [String: AnyObject], headers: [String: String], firstLaunch: Bool) {
        let urlwithPercentEscapes = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        Alamofire.request(urlwithPercentEscapes!, method: .get, parameters: params, headers: headers)
            .responseJSON { response in
                print(response.response ?? "")
                
                let jsonObj = JSON(data: response.data!)
                if jsonObj != JSON.null  {
                    self.syncTwitterTimeLine(twittersJSONObject: jsonObj, firstLaunch: firstLaunch)
                }
        }
    }
    
    open func getNextTwitterPosts () {
        
        // We need a new token, token expires every time we did a request
        authenticate {
            
            guard let token = self.accessToken else {
                // TODO: Show authentication error
                return
            }
            
            let headers = ["Authorization": "Bearer \(token)"]
            let params: [String : AnyObject] = [
                "screen_name" : self.screenName as AnyObject,
                "count": self.pageSize as AnyObject,
                "max_id": self.maxPostId as AnyObject
            ]
            self.loadUrl(urlString: self.baseUrlString + "statuses/user_timeline.json", params: params, headers: headers, firstLaunch: false)
        }
        
    }
    
    open func syncTwitterTimeLine(twittersJSONObject: JSON, firstLaunch: Bool) {
        
        var twitterPostsArray: [SocialObject] = []
        
        for i in 0..<twittersJSONObject.count {
            
            if i == 0 && !firstLaunch {
                // If we are not in first launch case that means we have called "more tweets" function with max_id info. Since max_id returns tweets with an ID less than (that is, older than) or EQUAL !!! we need to exclude first result (which is already loaded)
                continue
            }
            
            // Text
            var tweetText: String = ""
            let textJson = twittersJSONObject[i]["text"]
            if textJson != JSON.null {
                tweetText = textJson.string!
            }
            else {
                // We stop parse, we might reach Rate Limit
                break
            }
            
            // Publication date
            let tweetCreatedAt: String = twittersJSONObject[i]["created_at"].string!
            
            let dateFor: DateFormatter = DateFormatter()
            // ex : Wed Oct 26 11:44:03 +0000 2016
            dateFor.dateFormat = "EEE MMM dd HH:mm:ss +zzzz yyyy"
            dateFor.locale = Locale.init(identifier: "en_GB")
            
            let date: NSDate? = dateFor.date(from: tweetCreatedAt) as NSDate?
            let publicationDate = date as! Date
            
            // Image urls
            var socialImage: SocialImage?
            let mediasJson = twittersJSONObject[i]["entities"]["media"]
            if mediasJson != JSON.null {
                for mediaJson in mediasJson.array! {
                    let imageUrl: String = mediaJson["media_url_https"].string!
                    let imageWidth: Int = mediaJson["sizes"]["medium"]["w"].int!
                    let imageHeight: Int = mediaJson["sizes"]["medium"]["h"].int!
                    socialImage = SocialImage(url: imageUrl, width: imageWidth, height: imageHeight)
                }
            }
            
            let socialObject = SocialObject.init(image: socialImage, text: tweetText, publicationDate: publicationDate as NSDate, type: .twitter)
            
            twitterPostsArray.append(socialObject)
            
            if i == twittersJSONObject.count-1 {
                // For last twitter post, we get the id
                maxPostId = twittersJSONObject[i]["id_str"].string!
            }
        }
        
        self.delegate?.syncTwitterFinished(twitterSocialObjects: twitterPostsArray)
    }
}
