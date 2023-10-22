//
//  ScrollViewOffset.swift
//  Gazette
//
//  Created by Noah Kamara on 19.10.23.
//

import SwiftUI

fileprivate enum ScrollOffsetNamespace {
	static let namespace = "scrollView"
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
	static var defaultValue: CGPoint = .zero
	
	static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}


struct ScrollViewOffsetTracker: View {
	var body: some View {
		GeometryReader { geo in
			Color.clear
				.preference(
					key: ScrollOffsetPreferenceKey.self,
					value: geo.frame(in: .scrollView).origin
				)
		}
		.frame(height: 0)
	}
}

extension View {
	func onScroll(
		action: @escaping (_ offset: CGPoint) -> Void
	) -> some View {
		self
			.onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: action)
	}
}
