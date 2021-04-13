//
//  Date+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Anton Ilinykh on 04.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

extension Date {	
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
	
	func adding(hours: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .hour, value: hours, to: self)!
	}
}
