//
//  SortOptions.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import Foundation
import SwiftUI
import GazetteDB

public struct ArticleSorting {
	var descriptors: [SortDescriptor<Article>] {
		let keyPath = switch mode {
		case .published: \Article.pubDate
		case .read: \Article.pubDate
		}
		
		return [SortDescriptor(keyPath, order: order)]
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
			order = switch order {
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
		ForEach(ArticleSorting.Mode.allCases, id:\.rawValue) { mode in
			Button(action: { value.setMode(mode) }, label: {
				Label {
					Text(mode.label)
				} icon: {
					if value.mode == mode {
						Image(systemName: value.order == .forward ? "arrow.down" : "arrow.up")
							.contentTransition(.symbolEffect(.replace.downUp.byLayer))
							.sensoryFeedback(.decrease, trigger: value.order == .reverse)
							.sensoryFeedback(.increase, trigger: value.order == .forward)
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
