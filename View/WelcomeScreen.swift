//
//  WelcomeScreen.swift
//  DingDong
//
//  Created by Minh Huynh on 2/17/25.
//

import SwiftUI

struct WelcomeScreen: View {
    @Binding var intro: PageIntro
    var size: CGSize
    
    //Animation Properties
    @State private var isViewShowing: Bool = false
    @State private var isWholeViewHidden: Bool = false
    @State private var isNavBarHidden: Bool = false
    var body: some View {
        VStack {
            GeometryReader {
                let size = $0.size
                VStack(spacing: 20, content: {
                    Image(intro.introAssetImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 500)
                        .clipShape(.rect)
                    
                    // Fade effect
                        .overlay {
                            LinearGradient(colors: [
                                .clear,
                                .clear,
                                .clear,
                                .white.opacity(0.1),
                                .white.opacity(0.5),
                                .white.opacity(0.9),
                                .white.opacity(1),
                            ], startPoint: .top, endPoint: .bottom)
                        }
                    // Moving up
                        .offset(x: isViewShowing ? 0 : -size.width)
//                        .opacity(isViewShowing ? 1 : 0)
                    
                    // Title & action
                    VStack(alignment: .leading) {
                        Text(intro.title)
                            .font(.custom("Merriweather-Black", size: 40))
                            .foregroundStyle(Color("AccentColor"))
                            .fontWeight(.black)
                            .padding(.bottom,5)
                        Text(intro.subTitle)
                            .font(Font.custom("Cambay-Regular", size: 16))
                        Spacer()
                        
                        if !intro.displayAction {
                            Group {
                                Spacer(minLength: 25)
                                CustomIndicatorView(totalPages: filteredPages.count, currentPage: filteredPages.firstIndex(of: intro) ?? 0)
                                    .frame(maxWidth: .infinity)
                                Spacer(minLength: 10)
                                
                                if intro != pageIntros.last {
                                    Button {
                                        changeIntro()
                                    } label: {
                                        Text("Continue")
                                            .fontWeight(.bold)
                                            .frame(width: size.width * 0.4)
                                            .padding(.vertical, 15)
                                            .background {
                                                Capsule().fill(.secondary)
                                            }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.bottom, 30)
                                } else {
                                    NavigationLink(destination: ScanRoomView()) {
                                        Text("Continue")
                                            .fontWeight(.bold)
                                            .frame(width: size.width * 0.4)
                                            .padding(.vertical, 15)
                                            .background {
                                                Capsule().fill(.secondary)
                                            }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.bottom, 30)
                                }
                            }
                            
                        } else {
                            
                        }
                    }
                    .padding()
                    // Moving down
                    .offset(x: isViewShowing ? 0 : size.width)
//                    .opacity(isViewShowing ? 1 : 0)
                })
                .ignoresSafeArea()
            }
        }
        // Whole view
        .offset(x: isWholeViewHidden ? size.width : 0)
//        .opacity(isWholeViewHidden ? 0 : 1)
        .overlay(alignment: .topLeading) {
            HStack {
                // No back on first page
                if intro != pageIntros.first, !isNavBarHidden {
                    Button(action: {
                        changeIntro(true)
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .contentShape(Rectangle())
                    })
                }
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.1)) {
                        isWholeViewHidden = true
                        isNavBarHidden = true
                    }
                }, label: {
                    if !isNavBarHidden {
                        Text("Skip")
                            .fontWeight(.semibold)
                    }
                })
            }
            .foregroundStyle(.black)
            .padding(.top, 1)
            .padding()
            
            
        }
        .onAppear(perform: {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.1)) {
                isViewShowing = true
            }
        })
    }
    
    func changeIntro(_ isPrevious: Bool = false) {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.1)) {
            isWholeViewHidden = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Update page
            if let index = pageIntros.firstIndex(of: intro), (isPrevious ? index != 0 : index != pageIntros.count - 1) {
                intro = isPrevious ? pageIntros[index - 1] : pageIntros[index + 1]
            } else {
                intro = isPrevious ? pageIntros[0] : pageIntros[pageIntros.count - 1]
            }
            //Re-animating split page
            isWholeViewHidden = false
            isViewShowing = false
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.1)) {
                isViewShowing = true
            }
        }
        
        
    }
    
    var filteredPages: [PageIntro] {
        return pageIntros.filter{!$0.displayAction}
    }
}
