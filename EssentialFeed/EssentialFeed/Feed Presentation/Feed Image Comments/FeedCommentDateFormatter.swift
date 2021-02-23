//
//  FeedCommentDateFormatter.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 15/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class FeedCommentDateFormatter {
	private init() {}
	
	public static func getRelativeDate(for date: Date, locale: Locale = .current) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		formatter.locale = locale
		let relativeDate = formatter.localizedString(for: date, relativeTo: Date())
		return relativeDate
	}
}
