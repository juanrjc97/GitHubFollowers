//
//  Date+Ext.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/20/22.
//

import Foundation

extension Date {
    
    func convertToMonthYearFormat() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: self)
    }
}
