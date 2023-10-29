//
//  SortOptions.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import Foundation
import GazetteDB
import SwiftUI

public struct ArticleSorting {
	var descriptors: [SortDescriptor<Article>] {
		let keyPath = switch self.mode {
		case .published: \Article.pubDate
		case .read: \Article.pubDate
		}
		
		return [SortDescriptor(keyPath, order: self.order)]
	}
	
	enum Mode: String, CaseIterable {
		case published
		case read
		
		var label: LocalizedStringKey {
			switch self {
			case .published:
				"Publish Date"
			case .read:
				"Read Date"
			}
		}
	}
	
	var mode: Mode = .published
	var order: SortOrder = .reverse
	
	mutating func setMode(_ mode: Mode) {
		if self.mode != mode {
			self.mode = mode
			self.order = .forward
		} else {
			self.order = switch self.order {
			case .forward: .reverse
			case .reverse: .forward
			}
		}
	}
}

struct SortingMenu: View {
	@Binding
	var value: ArticleSorting
	
	var body: some View {
		ForEach(ArticleSorting.Mode.allCases, id: \.rawValue) { mode in
			Button(action: { self.value.setMode(mode) }, label: {
				Label {
					Text(mode.label)
				} icon: {
					if self.value.mode == mode {
						Image(systemName: self.value.order == .forward ? "arrow.down" : "arrow.up")
							.contentTransition(.symbolEffect(.replace.downUp.byLayer))
							.sensoryFeedback(.decrease, trigger: self.value.order == .reverse)
							.sensoryFeedback(.increase, trigger: self.value.order == .forward)
					}
				}
			})
			.tag(mode)
		}
	}
}

#Preview {
	@State var sorting = ArticleSorting()
	return SortingMenu(value: $sorting)
}
