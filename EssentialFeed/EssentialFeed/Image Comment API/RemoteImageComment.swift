//
//  RemoteImageComment.swift
//  EssentialFeed
//
//  Created by Ángel Vázquez on 19/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteImageComment: Decodable {
   struct Author: Decodable {
	   let username: String
   }
   
   let id: UUID
   let message: String
   let createdAt: Date
   let author: Author
   
   var imageComment: ImageComment {
	   ImageComment(id: id, message: message, creationDate: createdAt, author: author.username)
   }
}
