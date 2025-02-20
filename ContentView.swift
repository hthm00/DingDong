import SwiftUI
import FirebaseCore


struct ContentView: View {
    init() {
        registerCustomFont(name: "Merriweather-Black")
        registerCustomFont(name: "Cambay-Regular")
        FirebaseApp.configure()
    }
    
    var body: some View {
//            HomeView(isActive: false)
//                .backgroundStyle(.white)
        SceneTemplateView()
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
    }
}

/// Scan Room View allows acess to camera to outline a 3D model of a room
struct ScanRoomView: View {
    @Environment(\.presentationMode) var presentationMode
    
    /// RoomController instance
    @ObservedObject var roomController = ScanRoomController.instance
    /// Condition when scanning is completed
    @State var doneScanning: Bool = false
    
    @Binding var isActive: Bool
    
    ///Animation Properties
    @State private var isViewShowing: Bool = false
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            VStack {
                ZStack (alignment: .bottom) {
                    /// Camera View
                    ScanRoomViewRepresentable().onAppear(perform: {
                        roomController.startSession()
                    })
                    .onDisappear(perform: {
                        roomController.stopSession()
                    })
                    .ignoresSafeArea()
                    
                    //                /// Share sheet
                    //                if doneScanning, let url = roomController.url {
                    //                    ShareLink(item: url) {
                    //                        Image(systemName: "square.and.arrow.up")
                    //                    }
                    //                    .font(.title)
                    //                }
                    // TODO: Remove this
                    /// Share sheet
                    if doneScanning, let url = roomController.url {
                        VStack {
                            Text("Complete!")
                                .font(.custom("Merriweather-Black", size: 40))
                                .foregroundStyle(Color("AccentColor"))
                                .fontWeight(.black)
                                .padding(.bottom,5)
                            Text("Now let's see what I can do.")
                                .font(Font.custom("Cambay-Regular", size: 16))
                            Spacer()
                            HStack (alignment: .center){
                                Spacer()
                                Button(action: {
                                    isActive.toggle()
                                }, label: {
                                    NavigationLink {
//                                        RoomLoaderView(url: url)
                                        SceneTemplateView()
                                    } label: {
                                        ZStack(alignment: .center){
                                            Image("Round-Button")
                                            Image(systemName: "checkmark")
                                                .resizable()
                                                .frame(width: 22, height: 18)
                                                .scaledToFit()
                                                .foregroundStyle(Color("AccentColor"))
                                        }
                                        .frame(width: 64, height: 64)
                                    }
                                })
                                Spacer()
                            }
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .overlay(alignment: .trailing) {
                                ShareLink(item: url) {
                                    Image(systemName: "square.and.arrow.up")
                                }
                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                .padding(.trailing, 30)
                            }
                        }
                        .offset(x: doneScanning ? 0 : size.width)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton(), trailing: DoneButton)
        }
    }
    
    /// Finish Scan Button
    var DoneButton: some View {
        VStack {
            /// Done button
            if doneScanning == false {
                Button(action: {
                    roomController.stopSession()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.1)) {
                            self.doneScanning = true
                        }
                    }
                }, label: {
                    ZStack(alignment: .center){
                        Color.gray
                            .opacity(0.5)
                        Text("Done")
                            .font(Font.custom("Cambay-Regular", size: 14)
                                .weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.top, 3)
                    }
                    .frame(width: 60, height: 32)
                    .cornerRadius(8)
                })
            }
        }
    }
}


