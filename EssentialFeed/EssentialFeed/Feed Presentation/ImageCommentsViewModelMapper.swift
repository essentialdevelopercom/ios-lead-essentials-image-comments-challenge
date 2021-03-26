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
		let relativeFormatter = RelativeDateTimeFormatter()
		
		return imageComments.map { imageComment in
			ImageCommentViewModel(
				authorUsername: imageComment.username,
				createdAt: convert(
					date: imageComment.createdAt,
					formatter: relativeFormatter,
					timeFormatConfiguration: timeFormatConfiguration),
				message: imageComment.message)
		}
	}
	
	private static func convert(date: Date, formatter: RelativeDateTimeFormatter, timeFormatConfiguration: TimeFormatConfiguration) -> String {
		formatter.locale = timeFormatConfiguration.locale
		return formatter.localizedString(
			for: date,
			relativeTo: timeFormatConfiguration.relativeDate())
	}
}
