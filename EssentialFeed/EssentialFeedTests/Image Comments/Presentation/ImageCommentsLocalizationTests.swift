//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Rakesh Ramamurthy on 01/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase, XCTestLocalization {
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		assertThatLocalizedStringsHaveKeysAndValuesForAllSupportedLocalizations(in: "ImageComments", for: ImageCommentsPresenter.self)
	}
}
