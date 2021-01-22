//
//  Author.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/21/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct Author: Decodable, Equatable {
	public let username: String
	
	public init(username: String) {
		self.username = username
	}
}
