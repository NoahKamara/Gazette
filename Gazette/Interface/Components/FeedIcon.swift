//
//  FeedIcon.swift
//  Gazette
//
//  Created by Noah Kamara on 18.10.23.
//

import SwiftUI
import GazetteDB
import SwatchKit

struct FeedIcon: View {
	let feed: Feed
	
	
    var body: some View {
		Group {
			if let asset = feed.icon {
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
