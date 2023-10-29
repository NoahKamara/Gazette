//
//  BookmarkArticleButton.swift
//  Gazette
//
//  Created by Noah Kamara on 27.10.23.
//

import GazetteDB
import SwiftUI

struct BookmarkArticleButton: View {
	let article: Article
	
	init(_ article: Article) {
		self.article = article
	}
	
	var body: some View {
		Button(action: { self.article.isBookmarked.toggle() }) {
			Label(self.article.isBookmarked ? "Remove bookmark" : "Bookmark", systemImage: "bookmark")
				.symbolVariant(self.article.isBookmarked ? .slash : .none)
		}
	}
}
