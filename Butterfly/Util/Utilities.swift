//
//  Utilities.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//

import UIKit

/// A class containing a common and useful methods
open class Utilities: NSObject {

    // MARK: - Date & Time
    
    class var jsonDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
    
    class var appDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
}
