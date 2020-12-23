//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Cronay on 23.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class ImageCommentLocalizationTests: XCTestCase, LocalizationTests {

	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "ImageComments"
		let presentationBundle = Bundle(for: ImageCommentsPresenter.self)
		checkAllStringsHaveKeysAndValuesForAllSupportedLanguages(in: table, for: presentationBundle)
	}
}
