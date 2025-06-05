//
//  ContentView.swift
//  FallsCreekWatch
//
//  Created by Paul Thornton on 3/6/2025.
//

import SwiftUI
import WebKit

// MARK: - WebView

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var webViewRef: WKWebView?

    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var parent: WebView
        var refreshControl = UIRefreshControl()

        init(parent: WebView) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // Handle messages from JavaScript if needed
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.refreshControl.endRefreshing()
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }

        @objc func didPullToRefresh(_ sender: UIRefreshControl) {
            if let webView = sender.superview?.subviews.first(where: { $0 is WKWebView }) as? WKWebView {
                webView.reload()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "appHandler")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = true

        // Add pull to refresh
        context.coordinator.refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.didPullToRefresh(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = context.coordinator.refreshControl

        webView.load(URLRequest(url: url))

        // Pass reference back to ContentView
        DispatchQueue.main.async {
            self.webViewRef = webView
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // You can update UI here if needed
    }
}

// MARK: - ContentView

struct ContentView: View {
    @State private var isLoading = true
    @State private var webViewRef: WKWebView? = nil

    var body: some View {
        ZStack(alignment: .top) {
            //if let localURL = Bundle.main.url(forResource: "index", withExtension: "html") {
                /*WebView(
                    url: localURL,
                    isLoading: $isLoading,
                    webViewRef: $webViewRef
                )*/
                
                
                WebView(
                    url: URL(string: "https://proteus-mx.github.io/Falls-Creek-Watch/index.html")!,
                    isLoading: $isLoading,
                    webViewRef: $webViewRef
                )
                
                
                
                
            //}

            VStack {
                HStack(spacing: 10) {
                    Button(action: {
                        webViewRef?.reload()
                    }) {
                        Image("AppIcon1024x1024")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 4)
                    }

                    Spacer()
                }
                .padding()

                Spacer()
            }
            .frame(maxWidth: .infinity)

            if isLoading {
                ZStack {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        Image("AppIcon1024x1024")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(radius: 10)

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)

                        Text("Falls Creek Watch")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.teal, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color.black.opacity(0.5), radius: 4, x: 2, y: 2)

                        Text("Loading...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
            }
        }
    }
}
