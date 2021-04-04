//
//  Date+TestHelpers.swift
//  EssentialFeedTests
//
//  Created by Anton Ilinykh on 04.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

extension Date {
	static var now: Date {
		let rounded = round(Date().timeIntervalSinceReferenceDate)
		return Date(timeIntervalSinceReferenceDate: rounded)
	}
}
