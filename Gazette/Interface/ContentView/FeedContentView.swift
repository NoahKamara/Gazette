//
//  FeedContentView.swift
//  Gazette
//
//  Created by Noah Kamara on 19.10.23.
//

import SwiftUI
import GazetteDB

struct ArticleViewProperties {
	static let `default` = Self(showsFeed: true)
	
	var showsFeed: Bool
}

fileprivate struct ArticleViewKey: EnvironmentKey {
	static var defaultValue: ArticleViewProperties = .default
}

extension EnvironmentValues {
	var articleProps: ArticleViewProperties {
		get { self[ArticleViewKey.self] }
		set { self[ArticleViewKey.self] = newValue }
	}
}

struct FeedContentView: View {
	@Bindable
	var feed: Feed
	
	@State
	private var isShowingBanner = true
	
	@State
	private var bannerOffset: CGFloat = 0
	
	@Environment(Navigation.self)
	var nav
	
	var body: some View {
		@Bindable var nav = nav
		ArticleCollectionView(
			content: .feed(feed),
			selection: $nav.article
		) {
			if let asset = feed.icon {
				AssetViewNew(asset: asset) {
					$0
						.scaledToFit()
				}
				.aspectRatio(1, contentMode: .fit)
				.clipShape(RoundedRectangle(cornerRadius: 10))
				.padding(10)
				.frame(height: 30)
				.frame(height: 100)
			}
		}
		.environment(\.articleProps.showsFeed, false)
		.refreshable {
			print("REFRESH")
		}
		.refreshable {
			print("REFRESH FEED")
			try? await Task.sleep(for: .seconds(2))
		}
		.navigationTitle(feed.title ?? "Untitled Feed")
#if !os(macOS)
		.toolbar {
			ToolbarItemGroup(placement: .secondaryAction) {
				Button(action: {}, label: {
					Label("Rename", systemImage: "pencil")
				})
				
				Button(action: {}, label: {
					Label("Style", systemImage: "paintpalette")
				})
			}
			
		}
		.navigationBarTitleDisplayMode(.inline)
#endif
		
	}
}

#Preview {
	ModelPreview(rss: .spon) { feed in
		NavigationStack {
			FeedContentView(feed: feed)
		}
		.environment(Navigation())
	}
}
