//
//  ArticleDetailView.swift
//  Gazette
//
//  Created by Noah Kamara on 17.10.23.
//

import GazetteDB
import Readability
import SwiftUI

private struct Header: View {
	let title: String?
	let pubDate: Date?
	let byline: String?
	let feed: Feed?
	
	@State
	private var showNavTitle: Bool = false
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack(alignment: .top) {
				if let feed {
					Menu {
						ViewFeedButton(feed)
						EditFeedButton(feed)
					} label: {
						Text(feed.title ?? "Untitled Feed")
							.frame(maxWidth: .infinity, alignment: .leading)
							.multilineTextAlignment(.leading)
					}
					.foregroundStyle(Color.accentColor)
				}
				
				if let date = pubDate {
					if Date.now.timeIntervalSince(date) < 60*60 {
						Text(date, format: .relative(presentation: .named, unitsStyle: .abbreviated))
					} else {
						Text(date, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
					}
				}
			}
			.foregroundStyle(.secondary)
			.fontWeight(.semibold)
			.font(.callout.smallCaps())
			.containerShape(RoundedRectangle(cornerRadius: 8))
			
			Text(self.title ?? "Untitled Article")
				.font(.largeTitle)
				.fontWeight(.heavy)
				.fontDesign(.serif)
				.lineLimit(3)
				.minimumScaleFactor(0.5)
			
			if let byline = byline {
				Text("by " + byline)
					.font(.callout)
					.foregroundStyle(.secondary)
			}
			ScrollViewOffsetTracker()
				.onScroll { point in
					let newValue = point.y < 10
					withAnimation(.interactiveSpring) {
						self.showNavTitle = newValue
					}
				}
		}
		.lineSpacing(0)
		.navigationTitle(self.showNavTitle ? self.title ?? "" : "")
	}
}

struct ArticleData {
	let byline: String?
	let content: [MarkupElement]
}

struct ArticleDetailView: View {
	@Environment(Navigation.self)
	private var navigation
	
	@Environment(\.dismiss)
	private var dismiss
	
	let article: Article
	
	@State
	private var showNavTitle: Bool = false
	
	@State
	var articleData: ArticleData? = nil
	
	@State
	var parsingFailed: Bool = false
	
	var body: some View {
		ScrollView {
			LazyVStack(alignment: .leading, spacing: 15) {
				// MARK: Header

				Header(
					title: self.article.title,
					pubDate: self.article.pubDate,
					byline: self.articleData?.byline,
					feed: self.article.feed
				)
				
				Divider()
				
				Group {
					if let data = articleData {
						ForEach(data.content.enumerated().map { $0 }, id: \.offset) { element in
							switch element.element {
							case .text(let text):
								Text((try? AttributedString(markdown: text)) ?? "")
							default:
								Text("Unknown")
									.foregroundStyle(.red)
							}
						}
					} else if let overview = article.descr {
						Text(overview)
					} else {
						Text("No Content")
					}
				}
				.task(id: "loader") {
					await self.load()
				}
				.environment(\.openURL, OpenURLAction { url in
					print("Opened URL", url)
					
					switch url.scheme {
					case "gazette":
						print("gazette link")
					case "https", "http":
						print("Other URL")
					default:
						print("Unknown URL")
					}
					return .handled
				})
			}
			.lineSpacing(4)
			.safeAreaPadding(15)
			.frame(maxWidth: 700)
			.frame(maxWidth: .infinity)
		}
		
		.toolbarTitleDisplayMode(.inline)
		.toolbar {
#if !os(macOS)
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					Button(action: {}) {
						Label("App Link", systemImage: "appclip")
					}
					
					ShareLink(item: self.article.url) {
						Label("Article Link", systemImage: "link")
					}
					
					Button(action: {}) {
						Label("Markdown", systemImage: "doc.richtext")
					}
				} label: {
					Image(systemName: "square.and.arrow.up")
				}
			}
			
			ToolbarItem(placement: .topBarTrailing) {
				Button(action: {}, label: {
					Image(systemName: "textformat")
				})
			}
			
			ToolbarItem(placement: .topBarTrailing) {
				Menu {
					Button(action: {}) {
						Text("HELLO")
					}
				} label: {
					Image(systemName: "ellipsis")
				}
			}
#endif
		}
		.onAppear {
			self.article.isRead = true
		}
	}
	
	func load() async {
		do {
			var request = URLRequest(url: article.url)
			request.setValue("Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
			let (data, _) = try await URLSession.shared.data(for: request)
			
			guard let htmlString = String(data: data, encoding: .utf8) else {
				return
			}
			
			print("PARSING?")
			let result = try await Readability.shared.parseArticle(url: self.article.url, html: htmlString)
			print("RESULT", result)
			
			let content: [MarkupElement] = if let markdown = result.content {
				flattenMarkdown(markdown: markdown)
			} else { [] }
			
			print(result.leadImageURL)
			
			let articleData = ArticleData(
				byline: result.author,
				content: content
			)
			
			Task { @MainActor in
				self.articleData = articleData
				self.parsingFailed = false
			}
		} catch {
			self.parsingFailed = true
			print("Error", error)
		}
	}
}

#Preview {
	ModelPreview(rss: .spon) { article in
		NavigationStack {
			ArticleDetailView(article: article)
				.background(.background.secondary)
				.environment(Navigation())
		}
	}
}
