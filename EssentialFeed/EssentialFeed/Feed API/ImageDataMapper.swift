//
//  ImageDataMapper.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 11.07.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageDataMapper {
	private enum Error: Swift.Error {
		case invalidData
	}
	
	public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> Data {
		guard response.isOK && !data.isEmpty else {
			throw Error.invalidData
		}
		
		return data
	}
}
