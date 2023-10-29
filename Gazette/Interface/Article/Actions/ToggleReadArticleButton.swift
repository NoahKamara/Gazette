//
//  ToggleReadArticleButton.swift
//  Gazette
//
//  Created by Noah Kamara on 27.10.23.
//

import GazetteDB
import SwiftUI

struct ToggleReadArticleButton: View {
	let article: Article
	
	init(_ article: Article) {
		self.article = article
	}
	
	var body: some View {
		Button(action: { self.article.isRead.toggle() }, label: {
			Label(self.article.isRead ? "Mark unread" : "Mark read", systemImage: "circle")
				.symbolVariant(self.article.isRead ? .slash : .none)
		})
	}
}
