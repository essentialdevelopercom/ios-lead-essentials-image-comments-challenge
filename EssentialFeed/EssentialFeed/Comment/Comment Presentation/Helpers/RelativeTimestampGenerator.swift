//
//  RelativeTimestampGenerator.swift
//  EssentialFeedTests
//
//  Created by Khoi Nguyen on 5/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RelativeTimestampGenerator {
	static var now: Date {
		return Date()
	}
	
	public static func generateTimestamp(with date: Date) -> String {

		// ask for the full relative date
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full

		// get exampleDate relative to the current date
		return formatter.localizedString(for: date, relativeTo: now)
	}
}
