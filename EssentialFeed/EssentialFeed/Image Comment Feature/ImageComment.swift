//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Ángel Vázquez on 17/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct ImageComment {
	struct Author {
		let username: String
	}
	
	let id: UUID
	let message: String
	let creationDate: Date
	let author: Author
}
