//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Lukas Bahrle Santana on 22/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation


public protocol ImageCommentsView {
	
}

public final class ImageCommentsPresenter {
	
	private let imageCommentsView: ImageCommentsView
	
	public static var title: String {
		return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
			 tableName: "ImageComments",
			 bundle: Bundle(for: FeedPresenter.self),
			 comment: "Title for the image comments view")
	}
	
	public init(imageCommentsView: ImageCommentsView){
		self.imageCommentsView = imageCommentsView
	}
}
