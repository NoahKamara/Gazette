//
//  ScrollViewOffset.swift
//  Gazette
//
//  Created by Noah Kamara on 19.10.23.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
	static var defaultValue: CGPoint = .zero
	
	static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

struct HeightPreferenceKey: PreferenceKey {
	static var defaultValue: CGFloat = .zero
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
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

struct ScrollHideTrigger: ViewModifier {
	@Binding
	var isShown: Bool
	
	func body(content: Content) -> some View {
		content
			.background(alignment: .bottom, content: {
				ScrollViewOffsetTracker()
			})
			.onScroll(action: { pos in
				self.isShown = pos.y <= 5
			})
	}
}

extension View {
	func isScrollHidden(_ value: Binding<Bool>) -> some View {
		self
			.modifier(ScrollHideTrigger(isShown: value))
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
