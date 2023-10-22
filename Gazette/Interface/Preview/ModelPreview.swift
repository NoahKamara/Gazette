//
//  File.swift
//  
//
//  Created by Noah Kamara on 16.10.23.
//

import SwiftData
import SwiftUI
import GazetteDB
import GazetteParsing

public struct ModelPreview<Model: PersistentModel, Content: View>: View {
	public typealias OnSetupFn = (Persistence) async throws -> Void
	
	let content: (Model) -> Content
	let onSetup: OnSetupFn
	
	public init(
		onSetup: @escaping OnSetupFn,
		@ViewBuilder
		content: @escaping (Model) -> Content
	) {
		self.content = content
		self.onSetup = onSetup
	}
	
	public init(
		rss feed: PreviewFeeds,
		@ViewBuilder
		content: @escaping (Model) -> Content
	) {
		self.init(rss: [feed], content: content)
	}
	public init(
		rss feeds: Set<PreviewFeeds> = .all,
		@ViewBuilder
		content: @escaping (Model) -> Content
	) {
		self.init(onSetup: { persistence in
			for feed in feeds {
				do {
					let feed = try await FeedParser().parse(url: feed.url)
					await persistence.insert(feed)
				} catch {
					print(error)
				}
			}
		}, content: content)
	}
	
	struct ContentView: View {
		public init(
			onSetup: @escaping OnSetupFn,
			@ViewBuilder
			content: @escaping (Model) -> Content
		) {
			self.content = content
			self.onSetup = onSetup
		}
		
		let content: (Model) -> Content
		let onSetup: (Persistence) async throws -> Void
		
		@Query private var models: [Model]
		@State private var waitedToShowIssue = false
		
		@Environment(\.modelContext) private var context
		
		var body: some View {
			if let model = models.first {
				content(model)
			} else {
				ContentUnavailableView {
					Label {
						Text(verbatim: "Could not load model for previews")
					} icon: {
						Image(systemName: "xmark")
					}
				}
				.opacity(waitedToShowIssue ? 1 : 0)
				.task {
					try? await Task.sleep(for: .seconds(1))
					waitedToShowIssue = true
					
				}
				.task {
					let persistence = Persistence(modelContainer: context.container)
					do {
						try await onSetup(persistence)
					} catch {
						print("Error during Setup", error)
					}
				}
			}
		}
	}
	
	public var body: some View {
		ContentView(onSetup: onSetup, content: content)
			.persistence(inMemory: true)
	}
}
