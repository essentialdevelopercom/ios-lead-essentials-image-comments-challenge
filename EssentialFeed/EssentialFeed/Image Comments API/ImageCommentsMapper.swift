//
//  ImageCommentMapper.swift
//  EssentialFeed
//
//  Created by Araceli Ruiz Ruiz on 09/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

final class ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteImageComment]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard isOK(response), let root = try? decoder.decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }

        return root.items
    }
}

private extension ImageCommentsMapper {
    static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
