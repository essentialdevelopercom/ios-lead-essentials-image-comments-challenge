//
//  ImageCommentsViewModelMapper.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 22/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class ImageCommentsViewModelMapper {
	public static func map(_ imageComments: [ImageComment], timeFormatConfiguration: TimeFormatConfiguration) -> [ImageCommentViewModel] {
		imageComments.map { imageComment in
			ImageCommentViewModel(
				id: imageComment.id.uuidString,
				authorUsername: imageComment.username,
				createdAt: convert(date: imageComment.createdAt, timeFormatConfiguration: timeFormatConfiguration),
				message: imageComment.message)
		}
	}
	
	public static func convert(date: Date, timeFormatConfiguration: TimeFormatConfiguration) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.locale = timeFormatConfiguration.locale
		return formatter.localizedString(
			for: date,
			relativeTo: timeFormatConfiguration.relativeDate())
	}
}
