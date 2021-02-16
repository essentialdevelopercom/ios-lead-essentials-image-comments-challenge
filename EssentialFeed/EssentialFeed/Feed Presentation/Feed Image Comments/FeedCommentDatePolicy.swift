//
//  FeedCommentDatePolicy.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 15/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class FeedCommentDatePolicy {
	private init() {}
	
	public static func getRelativeDate(for date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let relativeDate = formatter.localizedString(for: date, relativeTo: Date())
		return relativeDate
	}
}
