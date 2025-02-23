//
//  GifImageView.swift
//
//
//  Created by Minh Huynh on 2/23/25.
//

import SwiftUI
import WebKit


struct GifImageView: UIViewRepresentable {
    private let name: String
    init(_ name: String) {
        self.name = name
    }
    
func makeUIView(context: Context) -> WKWebView {
    let webview = WKWebView()
    let url = Bundle.main.url(forResource: name, withExtension: "gif")!
    let data = try! Data(contentsOf: url)
    webview.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
    return webview
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }
}

#Preview {
    ZStack {
        Color.black
        VStack {
            GifImageView("drag-gesture")
                .frame(width: 100, height: 100)
        }
        .background(Color.red)
        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
//        .frame(width: 300, height: 300)
    }
}
