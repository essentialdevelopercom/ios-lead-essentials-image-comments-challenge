//
//  Date+Extension.swift
//  EssentialAppTests
//
//  Created by Maxim Soldatov on 12/1/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

extension Date {
	
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
	
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}
