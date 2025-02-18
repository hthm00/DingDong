import SwiftUI

struct ContentView: View {
    init() {
        registerCustomFont(name: "Merriweather-Black")
        registerCustomFont(name: "Cambay-Regular")
    }
    
    var body: some View {
        HomeView()
    }
    
    func registerCustomFont(name: String) {
        guard let fontURL = Bundle.main.url(forResource: name , withExtension: "ttf"),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            print("Failed to load font")
            return
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            print("Error registering font: \(String(describing: error))")
        }
    }
}

struct HomeView: View {
    // View Properties
    @State private var activeIntros: PageIntro = pageIntros[0]
    var body: some View {
        GeometryReader {
            let size = $0.size
            WelcomeScreen(intro: $activeIntros, size: size)
        }
    }
}

