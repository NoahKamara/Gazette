//
//  FeedEditView.swift
//  Gazette
//
//  Created by Noah Kamara on 18.10.23.
//

import SwiftUI

struct FormField<Content: View>: View {
	let content: Content

	init(
		@ViewBuilder
		content: () -> Content
	) {
		self.content = content()
	}
	var body: some View {
		content
			.padding(10)
			.frame(maxWidth: .infinity)
			.background(in: ContainerRelativeShape())
			.backgroundStyle(.background.tertiary)
	}
}

extension FormField {
	func labeled<Title: View>(_ title: Title) -> some View {
		VStack(alignment: .leading, spacing: 2) {
			title
				.font(.caption.smallCaps())
				.foregroundStyle(.secondary)
				.padding(.horizontal, 12)
			self
		}
	}
	
	func labeled(_ titleKey: LocalizedStringKey) -> some View {
		self.labeled(Text(titleKey))
	}
}

struct Sheet<Title: View, Content: View>: View {
	let title: Title
	let content: Content
	
	init(
		@ViewBuilder title: () -> Title,
		@ViewBuilder content: () -> Content
	) {
		self.title = title()
		self.content = content()
	}
	
	init(
		_ titleKey: LocalizedStringKey,
		@ViewBuilder content: () -> Content
	) where Title == Text {
		self.init(title: {
			Text(titleKey)
		}, content: content)
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			content
				.safeAreaPadding(10)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.safeAreaInset(edge: .top, spacing: 5) {
			title
				.font(.title2)
				.fontWeight(.semibold)
				.frame(maxWidth: .infinity)
				.safeAreaPadding(.horizontal, 20)
				.safeAreaPadding(.top, 15)
		}
		.background(.background, in: ContainerRelativeShape())
		.containerShape(RoundedRectangle(cornerRadius: 25))
		.padding(.horizontal, 10)
		.presentationBackground(.clear)
	}
}

extension Sheet {
//	func title<T: View>(@ViewBuilder title: () -> T) -> Sheet<T,Content> {
//		Sheet(title: title, content: content)
//	}
	
	func title(_ titleKey: String) -> Sheet<Text,Content> {
		Sheet<Text,Content>(title: { Text(titleKey) }, content: {content})
	}
}

import GazetteCore

import GazetteParsing

struct AddFeedSheet: View {
	@State
	var feedURL: URL?
	
	@State
	var feed: Feed? = nil
	
	@Environment(\.modelContext)
	var context
	
	@State
	var isLoading: Bool = false
	
	@Environment(\.dismiss)
	private var dismiss

	func attemptLoad() {
		guard !isLoading else { return }
		
		isLoading = true
		guard let feedURL else {
			return
		}
		
		let parser = FeedParser()
		
		Task {
			let result = try await parser.parse(url: feedURL)
			let persistence = Persistence(modelContainer: context.container)
			
			let feed = await persistence.insert(result)
			
			Task { @MainActor in
				self.feed = feed
			}
			isLoading = false
		}
	}
	
	var body: some View {
		Sheet("Add Feed") {
			FormField {
				TextField("Feed URL", value: $feedURL, format: .url)
			}
			.labeled("Feed URL")
			
			Button(action: attemptLoad) {
				Group {
					if isLoading {
						ProgressView()
					} else {
						Text("Continue")
					}
				}
				.fontWeight(.bold)
				.font(.title3)
				.padding(10)
				.frame(maxWidth: .infinity)
				.background(in: ContainerRelativeShape())
				.foregroundStyle(Color.accentColor)
				.backgroundStyle(Color.accentColor.quaternary)
			}
			.disabled(feedURL == nil && isLoading)
		}
		.presentationDetents([.fraction(0.3)])
		.sheet(item: $feed, onDismiss: { try? context.save(); dismiss() }) { feed in
			FeedEditView(feed: feed)
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
		}
}


import GazetteDB

struct FeedEditView: View {
	@Bindable
	var feed: Feed
	
	@Environment(\.dismiss)
	private var dismiss
	
    var body: some View {
		Sheet("Edit Feed") {
			if let banner = feed.image {
				FormField {
					AssetView(asset: banner)
						.padding(20)
				}
			}
			
			FormField {
				Label {
					TextField("", text: $feed.title ?? "")
				} icon: {
					FeedIcon(feed: feed)
						.containerShape(RoundedRectangle(cornerRadius: 5))
				}
			}
			.labeled("Title")
			.frame(maxHeight: .infinity)
			
			Button(action: { dismiss() }) {
				Text("Continue")
					.fontWeight(.bold)
					.font(.title3)
					.padding(10)
					.frame(maxWidth: .infinity)
					.background(in: ContainerRelativeShape())
					.foregroundStyle(Color.accentColor)
					.backgroundStyle(Color.accentColor.quaternary)
			}
		}
		
		.presentationDetents(feed.image != nil ? [.medium] : [.fraction(0.2)])
		
//		.safeAreaPadding(10)
//		.presentationDetents([.fraction(0.2), .medium])
    }
}

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
	Binding {
		lhs.wrappedValue ?? rhs
	} set: { newValue in
		lhs.wrappedValue = newValue
	}
}

#Preview("Feed Edit") {
	ModelPreview(rss: .spon) {
		FeedEditView(feed: $0)
	}
}

