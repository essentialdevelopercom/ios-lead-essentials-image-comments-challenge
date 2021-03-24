//
//  CommentErrorView.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public class CommentErrorView: UIView {
	
	@IBOutlet public var button: UIButton?
	
	public var message: String? {
		get { return button?.title(for: .normal) }
	}
	
	func show(message: String) {
		button?.setTitle(message, for: .normal)
	}
	
	@IBAction func hideMessage() {
		button?.setTitle(nil, for: .normal)
	}
}
