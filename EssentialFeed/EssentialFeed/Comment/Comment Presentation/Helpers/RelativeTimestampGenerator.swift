//
//  RelativeTimestampGenerator.swift
//  EssentialFeedTests
//
//  Created by Khoi Nguyen on 5/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RelativeTimestampGenerator {
	private static var now: Date {
		return Date()
	}
	
	public static func generate(with date: Date, in locale: Locale) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		formatter.locale = locale
		return formatter.localizedString(for: date, relativeTo: now)
	}
}
