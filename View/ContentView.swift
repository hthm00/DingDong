import SwiftUI
import FirebaseCore


struct ContentView: View {
    init() {
        registerCustomFont(name: "Merriweather-Black")
        registerCustomFont(name: "Cambay-Regular")
        FirebaseApp.configure()
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            SceneTemplateView()
        } else {
            HomeView(isActive: false)
                .backgroundStyle(.white)
        }
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
    @State private var activeIntros: PageIntro = pageIntros[2]
    @State var isActive: Bool
    @State private var isShowingScanView = false
    var body: some View {
        GeometryReader {
            let size = $0.size
            WelcomeScreen(intro: $activeIntros, isActive: $isActive, size: size)
//            ScanRoomView(isActive: $isActive)
        }
        .navigationBarBackButtonHidden(true)
    }
}

