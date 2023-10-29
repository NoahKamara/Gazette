//
//  FeedContentView.swift
//  Gazette
//
//  Created by Noah Kamara on 19.10.23.
//

import GazetteDB
import SwiftData
import SwiftUI

struct ArticleViewProperties {
	static let `default` = Self(showsFeed: true)
	
	var showsFeed: Bool
}

private struct ArticleViewKey: EnvironmentKey {
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
	
	private var feedID: PersistentIdentifier {
		self.feed.persistentModelID
	}
	
	var body: some View {
		@Bindable var nav = nav
		ArticleCollectionView2(
			predicate: #Predicate<Article> { article in
				article.feed?.persistentModelID == self.feedID
			},
			selection: $nav.article
		) {
			if let asset = feed.image {
				AssetViewNew(asset: asset) {
					let size = PlatformImage(data: asset.data ?? Data())?.size ?? .zero
					
					$0
						.resizable()
						.scaledToFit()
						.frame(maxWidth: size.width, maxHeight: size.height)
				}
				.clipShape(RoundedRectangle(cornerRadius: 5))
				.frame(height: 60)
				.padding(.horizontal, 30)
				.frame(height: 100)
			}
		}
		.environment(\.articleProps.showsFeed, false)
		.refreshable {
			print("REFRESH FEED")
			try? await Task.sleep(for: .seconds(2))
		}
		.navigationTitle(self.feed.title ?? "Untitled Feed")
		.toolbar {
			ToolbarItemGroup(placement: .secondaryAction) {
				EditFeedButton(self.feed)
			}
			ToolbarItemGroup(placement: .secondaryAction) {
				ShareFeedButton(self.feed)
			}
		}
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
