//
//  ArticleView.swift
//  Gazette
//
//  Created by Noah Kamara on 21.10.23.
//

import SwiftUI
import Readability
import HTML2Markdown


struct ArticleView: View {
	let url = URL(string: "https://www.spiegel.de/wissenschaft/internet-der-tiere-alzheimer-dystopie-auf-raedern-die-lese-empfehlungen-der-woche-a-39a8e288-9cef-407c-adb2-646b14a23d66")!
	
	
	@State
	var articleData: ReadabilityArticle? = nil
	
	@State
	var articleText: String? = nil
	
    var body: some View {
		if let articleData {
			ScrollView {
				LazyVStack(alignment: .leading) {
					Text(articleData.content ?? "")
				}
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			.frame(maxWidth: .infinity)
		} else {
			Text("Hello, World!")
				.task {
					do {
						var request = URLRequest(url: url)
						request.setValue("Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
						let (data, _ ) = try await URLSession.shared.data(for: request)
						
						guard let htmlString = String(data: data, encoding: .utf8) else {
							return
						}
						
						print(htmlString)
						
						let result = try await Readability.shared.parseArticle(url: url, html: htmlString)
						self.articleData = result
						
						
//						guard let content = result.content else { return }
//						
//						let parser = HTMLParser()
//						let md = try parser.parse(html: content).toMarkdown()
//						self.articleText = md
					} catch {
						print("Error", error)
					}
				}
		}
    }
}

#Preview {
    ArticleView()
}
