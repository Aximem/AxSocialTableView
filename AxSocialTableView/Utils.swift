//
//  Utils.swift
//  AxSocialTableView
//
//  Created by Maxime Charruel on 17/01/2017.
//  Copyright © 2017 Maxime Charruel. All rights reserved.
//

import Foundation
import SnapKit

public extension String {
    func getBase64() -> String {
        let credentialData = self.data(using: String.Encoding.utf8)!
        return credentialData.base64EncodedString(options: [])
    }
}

public extension UIImage {
    public class func bundledImage(named: String) -> UIImage? {
        let image = UIImage(named: named)
        if image == nil {
            return UIImage(named: named, in: Bundle(for: AppDelegate.classForCoder()), compatibleWith: nil)
        }
        return image
    }
}

public extension UIImageView {
    public func downloadedFrom(url: URL) {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.startAnimating()
        
        self.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(20)
            make.center.equalTo(self)
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
                let delegate = UIApplication.shared.delegate as? AppDelegate
                delegate?.applicationImageViewDictionary[url.absoluteString] = image
                activityIndicator.stopAnimating()
            }
            }.resume()
    }
    public func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        // We have a loading image
        self.image = UIImage.bundledImage(named: "no-image")
        
        // First we check if image is already saved in AppDelegate image array
        let delegate = UIApplication.shared.delegate as? AppDelegate
        guard let image = delegate?.applicationImageViewDictionary[link] else {
            // Image doesn't exists in AppDelegate image array
            guard let url = URL(string: link) else { return }
            downloadedFrom(url: url)
            return
        }
        self.image = image
    }
}

public enum SocialType: Int {
    case twitter = 0
    case facebook
    case instagram
}

public struct SocialImage: Equatable, Hashable {
    let url: String
    let width: Int
    let height: Int
    
    public var hashValue: Int {
        get {
            return url.hashValue
        }
    }
    
    public static func ==(lhs: SocialImage, rhs: SocialImage) -> Bool {
        return lhs.url == rhs.url && lhs.width == rhs.width && lhs.height
            == rhs.height
    }
}

public struct SocialObject: Equatable, Hashable {
    
    let image: SocialImage?
    let text: String
    let publicationDate: NSDate
    let type: SocialType
    
    public var hashValue: Int {
        get {
            return type.hashValue + publicationDate.hashValue
        }
    }
    
    public static func ==(lhs: SocialObject, rhs: SocialObject) -> Bool {
        return lhs.type == rhs.type && lhs.publicationDate == rhs.publicationDate && lhs.image
            == rhs.image && lhs.text == rhs.text
    }
}

class Utils {
    public static func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return String(format: NSLocalizedString("years_ago", comment: ""), "\(components.year!)")
        } else if (components.year! >= 1){
            if (numericDates){
                return String(format: NSLocalizedString("year_ago", comment: ""), "1")
            } else {
                return NSLocalizedString("last_year", comment: "")
            }
        } else if (components.month! >= 2) {
            return String(format: NSLocalizedString("months_ago", comment: ""), "\(components.month!)")
        } else if (components.month! >= 1){
            if (numericDates){
                return String(format: NSLocalizedString("month_ago", comment: ""), "1")
            } else {
                return NSLocalizedString("last_month", comment: "")
            }
        } else if (components.weekOfYear! >= 2) {
            return String(format: NSLocalizedString("weeks_ago", comment: ""), "\(components.weekOfYear!)")
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return String(format: NSLocalizedString("week_ago", comment: ""), "1")
            } else {
                return NSLocalizedString("last_week", comment: "")
            }
        } else if (components.day! >= 2) {
            return String(format: NSLocalizedString("days_ago", comment: ""), "\(components.day!)")
        } else if (components.day! >= 1){
            if (numericDates){
                return String(format: NSLocalizedString("day_ago", comment: ""), "1")
            } else {
                return NSLocalizedString("last_day", comment: "")
            }
        } else if (components.hour! >= 2) {
            return String(format: NSLocalizedString("hours_ago", comment: ""), "\(components.hour!)")
        } else if (components.hour! >= 1){
            if (numericDates){
                return String(format: NSLocalizedString("hour_ago", comment: ""), "1")
            } else {
                return NSLocalizedString("last_hour", comment: "")
            }
        } else if (components.minute! >= 2) {
            return String(format: NSLocalizedString("minutes_ago", comment: ""), "\(components.minute!)")
        } else if (components.minute! >= 1){
            if (numericDates){
                return String(format: NSLocalizedString("minute_ago", comment: ""), "1")
            } else {
                return NSLocalizedString("last_minute", comment: "")
            }
        } else if (components.second! >= 3) {
            return String(format: NSLocalizedString("seconds_ago", comment: ""), "\(components.second!)")
        } else {
            return NSLocalizedString("just_now", comment: "")
        }
    }
}
