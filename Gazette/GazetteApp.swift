//
//  GazetteApp.swift
//  Gazette
//
//  Created by Noah Kamara on 16.10.23.
//

import ArticleViewer
import SwiftUI

@main
struct GazetteApp: App {
	var body: some Scene {
		WindowGroup {
			MainView()
				.persistence(inMemory: false)
		}
	}
}
