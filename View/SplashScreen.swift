//
//  SplashScreen.swift
//
//
//  Created by Minh Huynh on 2/23/25.
//

import SwiftUI
import AVFoundation
import DotLottie

struct SplashScreenView: View {
    @State private var player: AVAudioPlayer?
    @Binding var isShowingHome: Bool
    
    var body: some View {
        ZStack {
            DotLottieAnimation(fileName: "bell-ding-dong", config: AnimationConfig(autoplay: true, loop: true)).view()
                .frame(width: 300)
                .onAppear {
                    playDingDongSound()
                    // Transition to main content after splash screen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeInOut) {
                            isShowingHome = true
                        }
                    }
                }
        }
    }
    
    private func playDingDongSound() {
        guard let soundURL = Bundle.main.url(forResource: "ding-dong", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}
