//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit

public final class ErrorView: UIButton {
	public var message: String? {
		get { return isVisible ? title(for: .normal) : nil }
		set { setMessageAnimated(newValue) }
	}
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		
		configure()
	}
	
	private func configure() {
		addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
		configureLabel()
		hideMessage()
	}
	
	private func configureLabel() {
		titleLabel?.textColor = .white
		titleLabel?.textAlignment = .center
		titleLabel?.numberOfLines = 0
		titleLabel?.font = .preferredFont(forTextStyle: .body)
		titleLabel?.adjustsFontForContentSizeCategory = true
	}
	
	private var isVisible: Bool {
		return alpha > 0
	}
	
	private func setMessageAnimated(_ message: String?) {
		if let message = message {
			showAnimated(message)
		} else {
			hideMessageAnimated()
		}
	}
	
	private func showAnimated(_ message: String) {
		setTitle(message, for: .normal)
		contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
		
		UIView.animate(withDuration: 0.25) {
			self.alpha = 1
		}
	}
	
	@objc private func hideMessageAnimated() {
		UIView.animate(
			withDuration: 0.25,
			animations: { self.alpha = 0 },
			completion: { completed in
				if completed {
					self.hideMessage()
				}
			})
	}
	
	private func hideMessage() {
		setTitle(nil, for: .normal)
		alpha = 0
		contentEdgeInsets = .init(top: -2.5, left: 0, bottom: -2.5, right: 0)
	}
}
