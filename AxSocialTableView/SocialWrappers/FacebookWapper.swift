//
//  FacebookWapper.swift
//  AxSocialTableView
//
//  Created by Maxime Charruel on 17/01/2017.
//  Copyright © 2017 Maxime Charruel. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public protocol FacebookWrapperDelegate {
    func syncFacebookFinished(facebookSocialObjects: [SocialObject])
}

class FacebookWrapper {
    
    var accessToken: String?
    
    var clientId: String?
    var clientSecret: String?
    var baseUrlString: String?
    var pageSize: Int?
    var screenName: String?
    
    var delegate: FacebookWrapperDelegate?
    
    var nextUrl: String?
    
    required public init(delegate: FacebookWrapperDelegate) {
        self.delegate = delegate
        
        self.clientId = ""
        self.clientSecret = ""
        self.baseUrlString = ""
        self.pageSize = 20
        self.screenName = ""
    }
    
    func authenticate(completionBlock: @escaping (Void) -> ()) {
        
        if accessToken != nil {
            completionBlock()
        }
        
        let urlString = String(format: "%@oauth/access_token?client_id=%@&client_secret=%@&grant_type=client_credentials", self.baseUrlString!, self.clientId!, self.clientSecret!)
        
        let urlwithPercentEscapes = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        Alamofire.request(urlwithPercentEscapes!, method: .get)
            .responseString { response in // WE USE responseString cause this API doesn't return a JSON
                
                if let result = response.result.value {
                    self.accessToken = result // format is like : access_token=1067008700003606|GvTOCPRNuvLMkT_5v-yO9IehFnQ
                    completionBlock()
                }
        }
    }
    
    func getFacebookPosts () {
        
        authenticate {
            
            guard let token = self.accessToken else {
                // TODO: Show authentication error
                return
            }
            
            let urlString = String(format: "%@%@/posts/?%@&date_format=U&fields=from,picture,message,story,name,link,created_time,full_picture&limit=%d", self.baseUrlString!, self.screenName!, token, self.pageSize!)
            
            self.loadUrl(urlString: urlString)
        }
    }
    
    func loadUrl (urlString: String) {
        let urlwithPercentEscapes = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        Alamofire.request(urlwithPercentEscapes!, method: .get)
            .responseJSON { response in
                let jsonObj = JSON(data: response.data!)
                if jsonObj != JSON.null  {
                    let data = jsonObj["data"]
                    if data != JSON.null {
                        self.syncFacebookTimeLine(facebooksJSONObject: data)
                    }
                    
                    let paging = jsonObj["paging"]
                    if paging != JSON.null {
                        self.nextUrl = paging["next"].string!
                    }
                }
        }
    }
    
    func getNextFacebookPosts () {
        self.loadUrl(urlString: nextUrl!)
    }
    
    func syncFacebookTimeLine(facebooksJSONObject: JSON) {
        
        var facebookPostsArray: [SocialObject] = []
        
        for i in 0..<facebooksJSONObject.count {
            
            var socialImage: SocialImage?
            let imageUrlJson = facebooksJSONObject[i]["full_picture"]
            if imageUrlJson != JSON.null {
                let imageUrl = imageUrlJson.string!
                socialImage = SocialImage(url: imageUrl, width: 720, height: 720)
            }
            
            var postMessage: String = ""
            let messageJson = facebooksJSONObject[i]["message"]
            if messageJson != JSON.null {
                postMessage = messageJson.string!
            }
            
            let postCreatedAtTimeStamp = facebooksJSONObject[i]["created_time"].int!
            let publicationDate = NSDate(timeIntervalSince1970: TimeInterval(postCreatedAtTimeStamp))
            
            let socialObject = SocialObject.init(image: socialImage, text: postMessage, publicationDate: publicationDate, type: .facebook)
            
            facebookPostsArray.append(socialObject)
        }
        
        self.delegate?.syncFacebookFinished(facebookSocialObjects: facebookPostsArray)
    }
}
