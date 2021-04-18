//
//  LocalizationHelpers.swift
//  EssentialFeedTests
//
//  Created by Ángel Vázquez on 27/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

protocol LocalizationTest: XCTestCase {}

extension LocalizationTest {
	typealias LocalizedBundle = (bundle: Bundle, localization: String)

	func allLocalizationBundles(in bundle: Bundle, file: StaticString = #filePath, line: UInt = #line) -> [LocalizedBundle] {
		return bundle.localizations.compactMap { localization in
			guard
				let path = bundle.path(forResource: localization, ofType: "lproj"),
				let localizedBundle = Bundle(path: path)
			else {
				XCTFail("Couldn't find bundle for localization: \(localization)", file: file, line: line)
				return nil
			}
			
			return (localizedBundle, localization)
		}
	}

	func allLocalizedStringKeys(in bundles: [LocalizedBundle], table: String, file: StaticString = #filePath, line: UInt = #line) -> Set<String> {
		return bundles.reduce([]) { (acc, current) in
			guard
				let path = current.bundle.path(forResource: table, ofType: "strings"),
				let strings = NSDictionary(contentsOfFile: path),
				let keys = strings.allKeys as? [String]
			else {
				XCTFail("Couldn't load localized strings for localization: \(current.localization)", file: file, line: line)
				return acc
			}
			
			return acc.union(Set(keys))
		}
	}
}

