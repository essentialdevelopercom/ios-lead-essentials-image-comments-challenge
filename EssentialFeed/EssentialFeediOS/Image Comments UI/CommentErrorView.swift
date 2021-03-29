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
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		button?.setTitle(nil, for: .normal)
		alpha = 0
	}
	
	private var isVisible: Bool { alpha > 0 }
	
	public var message: String? {
		get { return isVisible ? button?.title(for: .normal) : .none }
	}
	
	func show(message: String) {
		button?.setTitle(message, for: .normal)
		
		UIView.animate(withDuration: 0.25) {
			self.alpha = 1
		}
	}
	
	@IBAction func hideMessage() {
		UIView.animate(
			withDuration: 0.25,
			animations: { self.alpha = 0 },
			completion: { completed in
				if completed {
					self.button?.setTitle(nil, for: .normal)
				}
			})
	}
}
