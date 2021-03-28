//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Bogdan Poplauschi on 28/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

final class ImageCommentsLocalizationTests: XCTestCase, XCTestCaseWithLocalization {
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		assertThatLocalizedStringsHaveKeysAndValuesForAllSupportedLocalizations(table: "ImageComments", in: Bundle(for: ImageCommentsPresenter.self))
	}
}
