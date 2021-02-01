//
//  ImageCommentModel.swift
//  FeedCommentMVP
//
//  Created by Alok Subedi on 01/02/2021.
//

struct ImageCommentModel {
    let username: String
    let date: String
    let comment: String
}

extension ImageCommentModel {
    var testComments: [ImageCommentModel] {
        return [
            ImageCommentModel(username: "Jen",
                              date: "2 weaks ago",
                              comment: "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged."),
            ImageCommentModel(username: "Megan",
                              date: "1 weak ago",
                              comment: "Lorem Ipsum has been the industry's standard dummy text."),
            ImageCommentModel(username: "Jim",
                              date: "3 days ago",
                              comment: "Cool. 👍"),
            ImageCommentModel(username: "Brian",
                              date: "1 day ago",
                              comment: "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged."),
            ImageCommentModel(username: "Jack",
                              date: "2 hours ago",
                              comment: "It has survived not only five centuries.\n.\n.\n.\n.\n.\n.\n.\n.\n🔥")
        ]
    }
}
