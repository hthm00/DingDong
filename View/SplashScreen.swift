//
//  SplashScreen.swift
//
//
//  Created by Minh Huynh on 2/23/25.
//

import SwiftUI
import AVFoundation
/// This package cause a crash when reopening the app after app installed
//import DotLottie

struct SplashScreenView: View {
    @State private var player: AVAudioPlayer?
    @Binding var isShowingHome: Bool
    
    @State private var count = 0
    @State private var isScaling = false
    
    var body: some View {
        ZStack {
            /// Does not crash first run
//            DotLottieAnimation(fileName: "bell-ding-dong", config: AnimationConfig(autoplay: true, loop: true)).view()
//                .frame(width: 300)
//
            if #available(iOS 17.0, *) {
                Image(systemName: "bell.and.waves.left.and.right.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundStyle(Color("AccentColor"))
                    .symbolEffect(.bounce, value: count)
                    .onAppear() {
                        count += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            count += 1
                        }
                    }
            } else {
                Image(systemName: "bell.and.waves.left.and.right.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundStyle(Color("AccentColor"))
                    .scaleEffect(isScaling ? 1.0 : 1.5)
                    .animation(.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true), value: isScaling)
                    .onAppear {
                        isScaling = true
                    }
            }
        }
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
