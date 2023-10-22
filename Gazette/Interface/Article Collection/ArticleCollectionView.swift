//
//  ArticleCollectionView.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import SwiftUI
import SwiftData
import GazetteDB

@Observable
class Articles {
	struct Filter {
		var feed: PersistentIdentifier?
	}
	typealias Model = Article
	var articles: [Model]
	
	var context: ModelContext? = nil {
		didSet { updateQuery() }
	}
	
	var filter: Filter = .init()
	
	var content: Navigation.Content? = nil
	var sortBy: [SortDescriptor<Article>] = [
		.init(\.pubDate, order: .reverse)
	]
	
	func setContext(_ context: ModelContext) {
		self.context = context
		self.updateQuery()
	}
	
	
	func updateQuery() {
		debugPrint("Updating Article Query")
		
		guard let context else {
			print("cant update, no context")
			return
		}

		debugPrint("Generating Predicate")
		
		let feedID: PersistentIdentifier? = if case let .feed(feed) = content { feed.persistentModelID } else { nil }
		if let feedID { debugPrint("Filtering by Feed") }
		
		
		let predicate = #Predicate<Article> { article in
			// Feed
			if let feedID { article.feed?.persistentModelID == feedID } else { true }
		}
		
		let descriptor = FetchDescriptor(predicate: predicate, sortBy: sortBy)
		
		do {
			let result = try context.fetch(descriptor)
			debugPrint("Query resulted in \(result.count) items")
			withMutation(keyPath: \.articles) {
				self.articles = result
			}
		} catch {
			print("ERROR", error)
		}
	}
	
	
	init(articles: [Article] = []) {
		self.articles = articles
	}
}

extension PredicateExpression<Bool> {
	func and<T: PredicateExpression<Bool>>(_ other: T) -> PredicateExpressions.Conjunction<Self,T> {
		PredicateExpressions.Conjunction(lhs: self, rhs: other)
	}
}

struct QueryRegisteringModifier: ViewModifier {
	@Environment(\.modelContext)
	var context
	
	var query: Articles
	
	func body(content: Content) -> some View {
		content
			.task {
				query.context = context
			}
	}
}

extension View {
	func registerQuery(_ query: Articles) -> some View {
		self.modifier(QueryRegisteringModifier(query: query))
	}
}

struct ArticleCollectionView<Banner: View>: View {
	@Environment(\.modelContext)
	private var context

	let banner: Banner
	
	init(
		content: Navigation.Content,
		selection: Binding<PersistentIdentifier?>,
		@ViewBuilder
		banner: () -> Banner
	) {
		let query = Articles()
		query.content = content
		self.banner = banner()
		self._query = State(initialValue: query)
		self._selection = selection
	}
	
	init(
		content: Navigation.Content,
		selection: Binding<PersistentIdentifier?>
	) where Banner == EmptyView {
		let query = Articles()
		query.content = content
		self.banner = EmptyView()
		self._query = State(initialValue: query)
		self._selection = selection
	}
	
	@State
	var query: Articles
	
	@Binding
	var selection: PersistentIdentifier?
	
	var body: some View {
		ScrollView {
			banner
			
			if query.articles.isEmpty {
				Text("These aren't the Articles you're looking for")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else {
				ArticleListView(
					query: query,
					selection: $selection
				)
			}
		}
		.task {
			query.setContext(context)
		}
	}
}

//#Preview("Article List") {
//	@State var sorting = ArticleSorting()
//	@State var selection = PersistentIdentifier?.none
//	
//	return ArticleCollectionView(
//		filter: nil,
//		sorting: $sorting,
//		selection: $selection
//	)
//}
