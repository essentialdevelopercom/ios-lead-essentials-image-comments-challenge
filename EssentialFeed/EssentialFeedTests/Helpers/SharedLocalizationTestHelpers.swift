//
//  SharedLocalizationTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Raphael Silva on 15/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

func localized(
	key: String,
	table: String,
	bundle: Bundle,
	file: StaticString = #filePath,
	line: UInt = #line
) -> String {
	let value = bundle.localizedString(
		forKey: key,
		value: nil,
		table: table
	)

	if value == key {
		XCTFail(
			"Missing localized string for key: \(key) in table: \(table)",
			file: file,
			line: line
		)
	}

	return value
}
