//
//  StaticListView.swift
//  Gazette
//
//  Created by Noah Kamara on 19.10.23.
//

import SwiftUI
import GazetteDB


struct StaticListContentView: View {
	init(
		_ titleKey: LocalizedStringKey,
		filter: Predicate<Article>
	) {
		self.title = Text(titleKey)
		self.query = Articles()
		self.query.content = .all
	}
	
	let title: Text
	
	@State
	var query: Articles
	
	@Environment(Navigation.self)
	var nav
	
    var body: some View {
		@Bindable var nav = nav
		ArticleListView(query: query, selection: $nav.article)
			.navigationTitle(title)
		#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
		#endif
    }
}

#Preview {
	StaticListContentView("All", filter: .all)
}
