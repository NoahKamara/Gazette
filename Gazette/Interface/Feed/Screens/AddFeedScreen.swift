//
//  AddFeedScreen.swift
//  Gazette
//
//  Created by Noah Kamara on 27.10.23.
//

import Foundation
import GazetteCore
import GazetteDB
import GazetteParsing
import SwiftUI
import SwiftUINavigation

private struct AddFeedSheet: View {
	@State
	var feedURL: URL?
	
	@Environment(\.dismiss)
	private var dismiss
	
	@Environment(\.modelContext)
	private var context

	@State
	private var isLoading: Bool = false
	
	@State
	private var feed: TransientFeed? = nil
	
	func loadFeed() async throws -> TransientFeed? {
		guard let feedURL else {
			debugPrint("No Feed URL")
			return nil
		}
		
		let parser = FeedParser()
		
		let feed = try await parser.parse(url: feedURL)
		return feed
	}
	
	func saveFeed(_ feed: TransientFeed) async {
		let persistence = Persistence(modelContainer: context.container)
		await persistence.insert(feed)
		try? await persistence.save()
		self.dismiss()
	}
	
	var body: some View {
		FormView {
			if let feed {
				Label {
					Text(feed.title ?? "Untitled Feed")
				} icon: {
					FeedIcon(asset: feed.icon)
						.clipShape(RoundedRectangle(cornerRadius: 10))
						.frame(height: 35)
				}
				.minimumScaleFactor(0.5)
				.lineLimit(1)
			} else {
				Label {
					TextField("Feed URL", value: self.$feedURL, format: .url)
				} icon: {
					Image(systemName: "link")
				}
			}
			
			FormButton(action: {
				guard let feed else {
					do {
						self.feed = try await self.loadFeed()
					} catch let error as FeedParsingError {
						print(error)
					} catch {
						print("Unknown error: \(error)")
					}
					return
				}
				
				await self.saveFeed(feed)
			}) {
				Text(feed != nil ? "Add feed" : "Find feed")
			}
//			.disabled(feedURL == nil && isLoading)
		}
		.onAppear {
			guard self.feedURL != nil else { return }
			Task {
				self.isLoading = true
				guard let feed else {
					self.feed = try? await self.loadFeed()
					return
				}
				
				await self.saveFeed(feed)
				self.isLoading = false
			}
		}
	}
}

extension View {
	func addFeedScreen() -> some View {
		self.sheet(for: /Navigation.SheetID.addFeed) { $url in
			AddFeedSheet(feedURL: url).customSheet()
		}
	}
}

#Preview("Add Feed") {
	@State var isPresented = true
	return Text("HEllo")
		.onTapGesture {
			isPresented.toggle()
		}
		.sheet(isPresented: $isPresented) {
			AddFeedSheet(feedURL: URL(string: "https://www.spiegel.de/schlagzeilen/tops/index.rss"))
				.customSheet()
		}
		.environment(Navigation())
}
