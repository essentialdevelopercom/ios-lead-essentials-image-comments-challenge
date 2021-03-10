//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Lukas Bahrle Santana on 26/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsLocalizationTests: XCTestCase {
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "ImageComments"
		let presentationBundle = Bundle(for: ImageCommentsPresenter.self)
		
		checkLocalizedStrings_haveKeysAndValuesForAllSupportedLocalizations(for: table, in: presentationBundle)
	}
}
