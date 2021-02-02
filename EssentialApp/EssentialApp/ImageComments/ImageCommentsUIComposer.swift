//
//  ImageCommentsUIComposer.swift
//  EssentialApp
//
//  Created by Lukas Bahrle Santana on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

class ImageCommentsUIComposer{
	static func imageCommentsComposedWith(loader: ImageCommentsLoader, currentDate: @escaping () -> Date = Date.init, locale: Locale = .current) -> ImageCommentsViewController{
		let controller = ImageCommentsViewController()
		
		let presenter = ImageCommentsPresenter(imageCommentsView: WeakRefVirtualProxy(controller), loadingView: WeakRefVirtualProxy(controller), errorView: WeakRefVirtualProxy(controller), currentDate: currentDate, locale: locale)
		
		controller.title = ImageCommentsPresenter.title
		controller.presenter = presenter
		controller.loader = loader
		
		return controller
	}
}
