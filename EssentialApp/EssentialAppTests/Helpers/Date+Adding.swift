//
//  Date+Adding.swift
//  EssentialAppTests
//
//  Created by Lukas Bahrle Santana on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
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
