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
		let oneHourAgo = Date().adding(seconds: -3600)
		let oneHourAgoTimestamp = RelativeTimestampGenerator.generateTimestamp(with: oneHourAgo)
		XCTAssertEqual(oneHourAgoTimestamp, "1 hour ago")
		
		let twoDaysAgo = Date().adding(days: -2)
		let twoDaysAgoTimestamp = RelativeTimestampGenerator.generateTimestamp(with: twoDaysAgo)
		XCTAssertEqual(twoDaysAgoTimestamp, "2 days ago")
	}
}

