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
    @Binding var title: String
    var body: some View {
        Text(self.title)
            .font(.custom("Merriweather-Black", size: 35))
            .foregroundStyle(Color("AccentColor"))
            .fontWeight(.black)
            .padding(.bottom,5)
    }
}

/// Body text
struct BodyText: View {
    @Binding var text: String
    var body: some View {
        Text(text)
            .font(Font.custom("Cambay-Regular", size: 16))
    }
}

/// PrimaryButton
struct PrimaryButton: View {
    /// Contents
    var text: String
    var image: String?
    var systemImage: String?
    var size: CGSize?
    
    /// Determines if the button will span horizontally to all its available spaces
    var willSpan: Bool = false
    
    var body: some View {
        if let size = size {
            HStack(alignment: .center, spacing: 10) {
                if let image = image {
                    Image(image)
                        .frame(width: 16, height: 16)
                }
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                
                Text(text)
                    .fontWeight(.bold)
                    .frame(width: willSpan ? size.width * 0.8 : size.width * 0.4)
                    .padding(.vertical, 15)
                    .background {
                        Capsule().fill(.secondary)
                    }
            }
            .padding(10)
            .frame(maxWidth: willSpan ? .infinity: nil, alignment: .center)
            .cornerRadius(8)
        }
    }
}

#Preview {
    PrimaryButton(text: "Continue")
}
