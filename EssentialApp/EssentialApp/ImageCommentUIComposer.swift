//
//  FeedImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Antonio Mayorga on 4/12/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public class ImageCommentUIComposer {
	public static func imageCommentComposedWith(loader: ImageCommentLoader) -> ImageCommentViewController {
		let imageCommentViewController = makeImageCommentViewController(loader)
		return imageCommentViewController
	}
	
	private static func makeImageCommentViewController(_ loader: ImageCommentLoader) -> ImageCommentViewController {
		let bundle = Bundle(for: ImageCommentViewController.self)
		let storyboard = UIStoryboard(name: "ImageComment", bundle: bundle)
		let imageCommentViewController = storyboard.instantiateInitialViewController() as! ImageCommentViewController
		
		imageCommentViewController.loader = loader
		return imageCommentViewController
	}
}
