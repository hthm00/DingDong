import SwiftUI
import AVKit
import FirebaseCore


struct ContentView: View {
    @State var isShowingHome: Bool = false
    
    init() {
        registerCustomFont(name: "Merriweather-Black")
        registerCustomFont(name: "Cambay-Regular")
        FirebaseApp.configure()
    }
    
    var body: some View {
        if isShowingHome {
            HomeView()
                .backgroundStyle(.white)
        } else {
            SplashScreenView(isShowingHome: $isShowingHome)
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
    @State private var activeIntros: PageIntro = pageIntros[0]
    @State private var isShowingScanView = false
    var body: some View {
        GeometryReader {
            let size = $0.size
            if #available(iOS 17.0, *) {
    //            SceneTemplateView()
                IntroView()
            } else {
//                IntroView(isActive: $isActive)
                //            WelcomeScreen(intro: $activeIntros, isActive: $isActive, size: size)
                WelcomeScreen(intro: $activeIntros, size: size)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct IntroView: View {
    /// Load an overview video
    @State var player = AVPlayer(url: Bundle.main.url(forResource: "roomplan-large", withExtension: "mp4")!)
    @State var isVideoCompleted = false
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            ZStack() {
                /// Video player
                Rectangle()
                    .foregroundColor(.clear)
                    .background (
                        VideoPlayer(player: player)
                            .aspectRatio(5/2, contentMode: .fill)
                            .onAppear {
                                self.player.play()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation(.easeInOut) {
                                        self.isVideoCompleted = true
                                    }
                                }
                            }
                    )
                    .overlay {
                        if isVideoCompleted {
                            LinearGradient(colors: [
                                .clear,
                                .clear,
                                .clear,
                                .clear,
                                .clear,
                                .white.opacity(0.1),
                                .white.opacity(0.5),
                                .white.opacity(0.9),
                                .white.opacity(1),
                            ], startPoint: .top, endPoint: .bottom)
                        }
                    }
                if isVideoCompleted {
                    /// Next button to next view
                    VStack(alignment: .trailing) {
                        Spacer()
                        Button {
                            
                        } label: {
                            NavigationLink(destination: SceneTemplateView()) {
                                PrimaryButton(text: "Next", size: size)
                            }
                        }
                    }
                    .padding(30)
                }
            }
        }
        .ignoresSafeArea(.all)
//        .customNavBar()
    }
}
