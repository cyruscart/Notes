//
//  Date+Extension.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import Foundation

extension Date {
    
    func getStringDate(style: DateFormatter.Style, timeStyle: DateFormatter.Style = .none) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = style
            dateFormatter.timeStyle = timeStyle
            dateFormatter.locale = Locale(identifier: "Ru_ru")
            return dateFormatter.string(from: self)
        }
}
