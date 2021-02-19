//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Raphael Silva on 15/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

final class ImageCommentsLocalizationTests: XCTestCase {

	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "ImageComments"
		let bundle = Bundle(
			for: ImageCommentsPresenter.self
		)

		assertLocalizedKeysAndValuesExist(
			in: bundle,
			table: table
		)
	}
}
