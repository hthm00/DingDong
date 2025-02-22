//
//  CustomIndicatorView.swift
//  DingDong
//
//  Created by Minh Huynh on 2/17/25.
//

import SwiftUI

struct CustomIndicatorView: View {
    // View Propertires
    var totalPages: Int
    var currentPage: Int
    var activeTint: Color = .black
    var inActiveTint: Color = .gray.opacity(0.5)
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) {
                Circle()
                    .fill(currentPage == $0 ? activeTint : inActiveTint)
                    .frame(width: 4, height: 4)
            }
        }
    }
}

#Preview {
    CustomIndicatorView(totalPages: 3, currentPage: 1)
}
