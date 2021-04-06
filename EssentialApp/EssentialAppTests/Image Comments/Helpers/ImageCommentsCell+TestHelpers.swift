//
//  ImageCommentsCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Alok Subedi on 06/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeediOS

extension ImageCommentsCell {
   var usernameText: String? {
	   return usernameLabel.text
   }
   
   var messageText: String? {
	   return message.text
   }
   
   var createdTimetext: String? {
	   return createdTimeLabel.text
   }
}
