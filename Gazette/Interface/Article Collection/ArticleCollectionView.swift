//
//  ArticleCollectionView.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import GazetteDB
import SwiftData
import SwiftUI

@Observable
class Articles {
	struct Filter {
		var feed: PersistentIdentifier?
	}

	typealias Model = Article
	var articles: [Model]
	
	var context: ModelContext? {
		didSet { self.updateQuery() }
	}
	
	var content: Navigation.Content?
	
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
		
		let feedID: PersistentIdentifier? = if case .feed(let feed) = content { feed.persistentModelID } else { nil }
		
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
	func and<T: PredicateExpression<Bool>>(_ other: T) -> PredicateExpressions.Conjunction<Self, T> {
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
				self.query.context = self.context
			}
	}
}

extension View {
	func registerQuery(_ query: Articles) -> some View {
		self.modifier(QueryRegisteringModifier(query: query))
	}
}

struct ArticleCollectionView2<Banner: View>: View {
	init(
		predicate: Predicate<Article>? = nil,
		selection: Binding<PersistentIdentifier?>,
		@ViewBuilder banner: () -> Banner
	) {
		self._articles = .init(filter: predicate)
		self._selection = selection
		self.banner = banner()
	}
	
	let banner: Banner
	
	@Query
	private var articles: [Article]
	
	@Binding
	var selection: PersistentIdentifier?
	
	var body: some View {
		ScrollView {
			self.banner
			
			if self.articles.isEmpty {
				Text("These aren't the Articles you're looking for")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else {
				LazyVStack(spacing: 0) {
					ForEach(self.articles) { article in
						NavigationLink(value: article) {
							ArticleListView.Row(article: article)
						}
						.buttonStyle(.plain)
						.safeAreaPadding(.horizontal, 15)
						.padding(.vertical, 5)
						.background {
							if self.selection == article.id {
								ContainerRelativeShape()
									.fill(Color.accentColor.quaternary)
							} else {
								EmptyView()
							}
						}
					}
				}
				.safeAreaPadding(.bottom, 20)
			}
		}
//		.task {
//			query.setContext(context)
//		}
	}
}

struct ArticleCollectionView<Banner: View>: View {
	@Environment(\.modelContext)
	private var context

	let banner: Banner
	
	init(
		content: Navigation.Content,
		selection: Binding<PersistentIdentifier?>,
		@ViewBuilder banner: () -> Banner
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
			self.banner
			
			if self.query.articles.isEmpty {
				Text("These aren't the Articles you're looking for")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else {
				ArticleListView(
					query: self.query,
					selection: self.$selection
				)
			}
		}
		.task {
			self.query.setContext(self.context)
		}
	}
}

// #Preview("Article List") {
//	@State var sorting = ArticleSorting()
//	@State var selection = PersistentIdentifier?.none
//
//	return ArticleCollectionView(
//		filter: nil,
//		sorting: $sorting,
//		selection: $selection
//	)
// }
