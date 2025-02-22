//
//  PageIntro.swift
//  DingDong
//
//  Created by Minh Huynh on 2/17/25.
//

import Foundation

struct PageIntro: Identifiable, Hashable {
    var id: UUID = .init()
    var introAssetImage: String
    var title: String
    var subTitle: String
    var displayAction: Bool = false
}

var pageIntros: [PageIntro] = [
    PageIntro(introAssetImage: "create-new-image", title: "Getting Started", subTitle: "Scan your room and design in an immersive experience that brings your vision to life"),
    PageIntro(introAssetImage: "personal-items", title: "Step 1", subTitle: "\u{2022} Remove all personal items\n\u{2022} Ensure room is empty of people"),
    PageIntro(introAssetImage: "closing-door", title: "Step 2", subTitle: "\u{2022} Close all doors\n\u{2022} Move back to get a great angle")
]
