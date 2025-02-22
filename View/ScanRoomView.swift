//
//  File.swift
//  
//
//  Created by Minh Huynh on 2/22/25.
//

import SwiftUI

/// Scan Room View allows acess to camera to outline a 3D model of a room
//struct ScanRoomView: View {
//    @Environment(\.presentationMode) var presentationMode
//    
//    /// RoomController instance
//    @ObservedObject var roomController = ScanRoomController.instance
//    /// Condition when scanning is completed
//    @State var doneScanning: Bool = false
//    
//    @Binding var isActive: Bool
//    
//    ///Animation Properties
//    @State private var isViewShowing: Bool = false
//    
//    var body: some View {
//        GeometryReader {
//            let size = $0.size
//            VStack {
//                ZStack (alignment: .bottom) {
//                    /// Camera View
//                    ScanRoomViewRepresentable().onAppear(perform: {
//                        roomController.startSession()
//                    })
//                    .onDisappear(perform: {
//                        roomController.stopSession()
//                    })
//                    .ignoresSafeArea()
//                    
//                    //                /// Share sheet
//                    //                if doneScanning, let url = roomController.url {
//                    //                    ShareLink(item: url) {
//                    //                        Image(systemName: "square.and.arrow.up")
//                    //                    }
//                    //                    .font(.title)
//                    //                }
//                    // TODO: Remove this
//                    /// Share sheet
//                    if doneScanning, let url = roomController.url {
//                        VStack {
//                            Text("Complete!")
//                                .font(.custom("Merriweather-Black", size: 40))
//                                .foregroundStyle(Color("AccentColor"))
//                                .fontWeight(.black)
//                                .padding(.bottom,5)
//                            Text("Now let's see what I can do.")
//                                .font(Font.custom("Cambay-Regular", size: 16))
//                            Spacer()
//                            HStack (alignment: .center){
//                                Spacer()
//                                Button(action: {
//                                    isActive.toggle()
//                                }, label: {
//                                    NavigationLink {
//                                        RoomLoaderView(url: url)
//                                    } label: {
//                                        ZStack(alignment: .center){
//                                            Image("Round-Button")
//                                            Image(systemName: "checkmark")
//                                                .resizable()
//                                                .frame(width: 22, height: 18)
//                                                .scaledToFit()
//                                                .foregroundStyle(Color("AccentColor"))
//                                        }
//                                        .frame(width: 64, height: 64)
//                                    }
//                                })
//                                Spacer()
//                            }
//                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
//                            .overlay(alignment: .trailing) {
//                                ShareLink(item: url) {
//                                    Image(systemName: "square.and.arrow.up")
//                                }
//                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
//                                .padding(.trailing, 30)
//                            }
//                        }
//                        .offset(x: doneScanning ? 0 : size.width)
//                    }
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationBarBackButtonHidden(true)
//            .navigationBarItems(leading: BackButton(), trailing: DoneButton)
//        }
//    }
//    
//    /// Finish Scan Button
//    var DoneButton: some View {
//        VStack {
//            /// Done button
//            if doneScanning == false {
//                Button(action: {
//                    roomController.stopSession()
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.1)) {
//                            self.doneScanning = true
//                        }
//                    }
//                }, label: {
//                    ZStack(alignment: .center){
//                        Color.gray
//                            .opacity(0.5)
//                        Text("Done")
//                            .font(Font.custom("Cambay-Regular", size: 14)
//                                .weight(.semibold))
//                            .foregroundStyle(.white)
//                            .padding(.top, 3)
//                    }
//                    .frame(width: 60, height: 32)
//                    .cornerRadius(8)
//                })
//            }
//        }
//    }
//}

import SwiftUI

/// Scan Room View allows acess to camera to outline a 3D model of a room
struct ScanRoomView: View {
    @Environment(\.presentationMode) var presentationMode
    
    /// RoomController instance
    @ObservedObject var roomController = ScanRoomController.instance
    /// Condition when scanning is completed
    @State var doneScanning: Bool = false
    
    @Binding var isActive: Bool
    
    var body: some View {
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
                    
                    HStack (alignment: .center){
                        Spacer()
                        Button {} label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Spacer()
                        Button(action: {
                            isActive.toggle()
                        }, label: {
                            ZStack(alignment: .center){
                                Image("Round-Button")
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .frame(width: 22, height: 18)
                                    .scaledToFit()
                            }
                            .frame(width: 64, height: 64)
                        })
                        
                        
                        Spacer()
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                            
                        }
                        Spacer()
                    }
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton(), trailing: DoneButton)
    }
    
    /// Finish Scan Button
    var DoneButton: some View {
        VStack {
            /// Done button
            if doneScanning == false {
                Button(action: {
                    roomController.stopSession()
                    self.doneScanning = true
                }, label: {
                    ZStack(alignment: .center){
                        Color("Grey")
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
