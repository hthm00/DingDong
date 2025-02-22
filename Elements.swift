//
//  Elements.swift
//  DingDong
//
//  Created by Minh Huynh on 2/17/25.
//

import SwiftUI

/// Custom Back Button
struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }){
            ZStack(alignment: .center){
                Color("Grey")
                    .opacity(0.5)
                Image("arrow-back")
                    .frame(width: 16, height: 12)
            }
            .frame(width: 32, height: 32)
            .cornerRadius(8)
        }
        .padding(.leading)
    }
}

/// Heading 1
struct H1Text: View {
    var title: String
    var body: some View {
        Text(self.title)
            .font(.custom("Merriweather-Black", size: 40))
            .foregroundStyle(Color("AccentColor"))
            .fontWeight(.black)
            .padding(.bottom,5)
    }
}

/// Body text
struct BodyText: View {
    var text: String
    var body: some View {
        Text(text)
            .font(Font.custom("Cambay-Regular", size: 16))
    }
}
