//
//  FeedIcon.swift
//  Gazette
//
//  Created by Noah Kamara on 18.10.23.
//

import GazetteCore
import GazetteDB
import SwatchKit
import SwiftUI

struct FeedIcon<A: AssetProtocol>: View {
	let asset: A?
	
	init(feed: Feed) where A == Asset {
		self.init(asset: feed.icon)
	}
	
	init(asset: A?) {
		self.asset = asset
	}
	
	var body: some View {
		Group {
			if let asset {
				AssetView(asset: asset)
			} else {
				Rectangle()
			}
		}
		.frame(width: 25, height: 25)
		.clipShape(ContainerRelativeShape())
		.aspectRatio(1, contentMode: .fit)
	}
}

#Preview {
	ModelPreview(rss: .welt) { feed in
		FeedIcon(feed: feed)
	}
}
