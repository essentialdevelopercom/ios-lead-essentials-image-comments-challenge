//
//  FeedErrorView.swift
//  EssentialFeed
//
//  Created by Ivan Ornes on 10/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedErrorView {
	func display(_ viewModel: FeedErrorViewModel)
}
