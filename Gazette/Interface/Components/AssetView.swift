//
//  AssetView.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import SwiftUI
import GazetteDB

#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

struct AssetViewNew<Content: View>: View {
	let asset: Asset

	private let content: (Image) -> Content
	
	init(asset: Asset, @ViewBuilder content: @escaping (Image) -> Content) {
		self.asset = asset
		self.content = content
	}
	
	@Environment(\.modelContext)
	private var context
	
	var body: some View {
		if let data = asset.data, let image = PlatformImage(data: data) {
			content(Image(image: image).renderingMode(.original))
		} else {
			ContainerRelativeShape()
				.foregroundStyle(.background)
				.task(id: asset.url, priority: .low) {
					if asset.data != nil {
						return
					}
					
					do {
						let (data, _) = try await URLSession.shared.data(from: asset.url)
						asset.data = data
						
						try context.save()
					} catch {
						debugPrint("error loading data for \(asset.url): \(error)")
						debugPrint(error)
					}
				}
		}
	}
}


struct AssetView: View {
	let asset: Asset
	
	let onLoad: ((PlatformImage) -> Void)?
	
	init(asset: Asset, onLoad: ((PlatformImage) -> Void)? = nil) {
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
					onLoad?(image)
				})
		} else {
			ContainerRelativeShape()
				.foregroundStyle(.ultraThickMaterial)
				.task(id: asset.url, priority: .low) {
					if asset.data != nil {
//						debugPrint("asset already has \(asset.url)")
						return
					}
					
					do {
						let (data, _) = try await URLSession.shared.data(from: asset.url)
						
//						debugPrint("downloaded data for \(asset.url)")
						asset.data = data
						
						try context.save()
					} catch {
						debugPrint("error loading data for \(asset.url): \(error)")
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
