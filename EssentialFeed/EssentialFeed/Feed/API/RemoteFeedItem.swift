//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Ilhan Sari on 25.01.2021.
//  Copyright © 2021 ilhan sarı. All rights reserved.
//

import Foundation

struct RemoteFeedItem: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let image: URL
}
