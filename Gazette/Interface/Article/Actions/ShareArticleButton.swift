//
//  ShareArticleButton.swift
//  Gazette
//
//  Created by Noah Kamara on 27.10.23.
//

import GazetteDB
import SwiftUI

struct ShareArticleButton: View {
	let article: Article
	
	init(_ article: Article) {
		self.article = article
	}
	
	var body: some View {
		ShareLink(item: self.article.url) {
			Label("Share article", systemImage: "link")
		}
	}
}
