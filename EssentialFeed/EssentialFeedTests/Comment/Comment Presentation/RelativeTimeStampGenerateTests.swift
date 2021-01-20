//
//  RelativeTimeStampGenerateTests.swift
//  EssentialFeedTests
//
//  Created by Khoi Nguyen on 5/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RelativeTimeStampGenerateTests: XCTestCase {
	
	func test_generateTimestamp_returnsRelativeTimestampCompareToNow() {
		let locale = Locale(identifier: "en_US_POSIX")
		let oneHourAgo = Date().adding(seconds: -3600)
		let oneHourAgoTimestamp = RelativeTimestampGenerator.generate(with: oneHourAgo, in: locale)
		XCTAssertEqual(oneHourAgoTimestamp, "1 hour ago")
		
		let twoDaysAgo = Date().adding(days: -2)
		let twoDaysAgoTimestamp = RelativeTimestampGenerator.generate(with: twoDaysAgo, in: locale)
		XCTAssertEqual(twoDaysAgoTimestamp, "2 days ago")
	}
}

