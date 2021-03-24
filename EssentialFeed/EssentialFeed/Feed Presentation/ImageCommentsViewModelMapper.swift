//
//  ImageCommentsViewModelMapper.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 22/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class ImageCommentsViewModelMapper {
	private static let relativeFormatter = RelativeDateTimeFormatter()
	
	public static func map(_ imageComments: [ImageComment], timeFormatConfiguration: TimeFormatConfiguration) -> [ImageCommentViewModel] {
		imageComments.map { imageComment in
			ImageCommentViewModel(
				authorUsername: imageComment.username,
				createdAt: convert(date: imageComment.createdAt, timeFormatConfiguration: timeFormatConfiguration),
				message: imageComment.message)
		}
	}
	
	private static func convert(date: Date, timeFormatConfiguration: TimeFormatConfiguration) -> String {
		relativeFormatter.locale = timeFormatConfiguration.locale
		return relativeFormatter.localizedString(
			for: date,
			relativeTo: timeFormatConfiguration.relativeDate())
	}
}
