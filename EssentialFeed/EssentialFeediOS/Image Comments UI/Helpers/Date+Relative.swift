//
//  Date+Relative.swift
//  EssentialFeediOS
//
//  Created by Araceli Ruiz Ruiz on 29/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public extension Date {
    func relativeDate(to date: Date = Date()) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: date)
    }
}

