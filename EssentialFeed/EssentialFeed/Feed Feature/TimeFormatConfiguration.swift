//
//  TimeFormatConfiguration.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 22/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class TimeFormatConfiguration {
	public let relativeDate: () -> Date
	public let locale: Locale
	
	public init(relativeDate: @escaping () -> Date, locale: Locale) {
		self.relativeDate = relativeDate
		self.locale = locale
	}
}
