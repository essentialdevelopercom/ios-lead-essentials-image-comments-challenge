//
//  Date+RelativeDate.swift
//  EssentialFeediOS
//
//  Created by Antonio Mayorga on 4/7/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public extension Date {
	func relativeDate(to date: Date = Date()) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		return formatter.localizedString(for: self, relativeTo: date)
	}
}
