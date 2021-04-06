//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by alok subedi on 02/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase, LocalizationTests{
	
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "ImageComments"
		let presentationBundle = Bundle(for: ImageCommentsPresenter.self)
		assertLocalization(for: table, in: presentationBundle)
	}
}
