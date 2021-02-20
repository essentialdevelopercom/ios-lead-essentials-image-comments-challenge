//
//  XCTestCase+Localization.swift
//  EssentialFeedTests
//
//  Created by Mario Alberto Barragán Espinosa on 19/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import XCTest
import EssentialFeed

extension XCTestCase {
	func localized(for classType: AnyClass,_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Feed"
		let bundle = Bundle(for: classType)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}
