//
//  JSONDecoder+Strategies.swift
//  EssentialFeed
//
//  Created by Ángel Vázquez on 19/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

extension JSONDecoder {
	func withKeyDecodingStrategy(_ strategy: JSONDecoder.KeyDecodingStrategy) -> JSONDecoder {
		self.keyDecodingStrategy = strategy
		return self
	}
	
	func withDateDecodingStrategy(_ strategy: JSONDecoder.DateDecodingStrategy) -> JSONDecoder {
		self.dateDecodingStrategy = strategy
		return self
	}
}
