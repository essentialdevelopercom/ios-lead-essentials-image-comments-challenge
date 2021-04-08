//
//  ImageCommentsUIIntegrationTests+Localization.swift
//  EssentialAppTests
//
//  Created by Bogdan Poplauschi on 02/04/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import XCTest
import EssentialFeed

extension ImageCommentsUIIntegrationTests {
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		return EssentialAppTests.localized(key, in: "ImageComments", from: Bundle(for: ImageCommentsPresenter.self))
	}
}
