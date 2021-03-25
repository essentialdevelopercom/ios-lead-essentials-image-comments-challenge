//
//  Localized.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 24/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

enum Localized {
	enum ImageComments {
		static var bundle = Bundle(for: ImageCommentsListPresenter.self)
		static var table: String { "ImageComments" }
		
		static var title: String {
			localizedString(
				for: "IMAGE_COMMENTS_VIEW_TITLE",
				table: table,
				bundle: bundle,
				comment: "Title for the image comments list screen"
			)
		}
		
		static var errorMessage: String {
			localizedString(
				for: "IMAGE_COMMENTS_VIEW_ERROR_MESSAGE",
				table: table,
				bundle: bundle,
				comment: "Error message to be presented when comments fail to load"
			)
		}
	}
	
	private static func localizedString(for key: String, table: String, bundle: Bundle, comment: String) -> String {
		NSLocalizedString(key, tableName: table, bundle: bundle, comment: comment)
	}
}
