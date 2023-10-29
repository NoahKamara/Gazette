//
//  AssetView.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import GazetteCore
import GazetteDB
import SwiftUI

#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

struct AssetViewNew<Content: View, A: AssetProtocol>: View {
	let asset: A

	private let content: (Image) -> Content
	
	init(asset: A, @ViewBuilder content: @escaping (Image) -> Content) {
		self.asset = asset
		self.content = content
	}
	
	@Environment(\.modelContext)
	private var context
	
	var body: some View {
		if let data = asset.data, let image = PlatformImage(data: data) {
			self.content(Image(image: image).renderingMode(.original))
		} else {
			ContainerRelativeShape()
				.foregroundStyle(.background)
				.task(id: self.asset.url, priority: .low) {
					if self.asset.data != nil {
						return
					}
					
					do {
						let (data, _) = try await URLSession.shared.data(from: asset.url)
						if let asset = self.asset as? Asset {
							asset.data = data
						}
						
						try self.context.save()
					} catch {
						debugPrint("error loading data for \(self.asset.url): \(error)")
						debugPrint(error)
					}
				}
		}
	}
}

struct AssetView<A: AssetProtocol>: View {
	let asset: A
	
	let onLoad: ((PlatformImage) -> Void)?
	
	init(asset: A, onLoad: ((PlatformImage) -> Void)? = nil) {
		self.asset = asset
		self.onLoad = onLoad
	}
	
	@Environment(\.modelContext)
	private var context
	
	var body: some View {
		if let data = asset.data, let image = PlatformImage(data: data) {
			Image(image: image)
				.resizable()
				.scaledToFit()
				.clipShape(ContainerRelativeShape())
				.onAppear(perform: {
					self.onLoad?(image)
				})
		} else {
			ContainerRelativeShape()
				.foregroundStyle(.ultraThickMaterial)
				.task(id: self.asset.url, priority: .low) {
					if self.asset.data != nil {
//						debugPrint("asset already has \(asset.url)")
						return
					}
					
					do {
						let (data, _) = try await URLSession.shared.data(from: asset.url)
						
//						debugPrint("downloaded data for \(asset.url)")
						if let asset = self.asset as? Asset {
							asset.data = data
						}
						
						try self.context.save()
					} catch {
						debugPrint("error loading data for \(self.asset.url): \(error)")
						debugPrint(error)
					}
				}
		}
	}
}

extension Image {
	init(image: PlatformImage) {
#if os(macOS)
		self.init(nsImage: image)
#else
		self.init(uiImage: image)
#endif
	}
}
