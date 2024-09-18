//
//  Modifiers.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 18.09.24.
//

import Foundation
import SwiftUI

protocol ChewTextStyle : ViewModifier {}

enum ChewTextSize : Int, CaseIterable, Equatable {
    case medium
    case big
    
    var chewTextStyle : ChewPrimaryStyle {
        switch self {
        case .medium:
            return .medium
        case .big:
            return .big
        }
    }
}

extension View {
    func textSize<Style: ChewTextStyle>(_ style: Style) -> some View {
        ModifiedContent(content: self, modifier: style)
    }
}

extension ViewModifier where Self == ChewPrimaryStyle {
    static var big: ChewPrimaryStyle {
        ChewPrimaryStyle(17,.body)
    }
    static var medium: ChewPrimaryStyle {
        ChewPrimaryStyle(14,.caption)
    }
}

struct ChewPrimaryStyle: ChewTextStyle {
    let size : CGFloat!
    let font : Font.TextStyle!
    init(_ size : CGFloat, _ font : Font.TextStyle){
        self.size = size
        self.font = font
    }
    func body(content: Content) -> some View {
        content
            .font(.system(size: size,weight: .semibold))
    }
}


#if DEBUG
struct Font_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(Font.TextStyle.allCases, id: \.hashValue, content: {
                Text("popopopo")
                    .font(.system($0))
            })
        }
    }
}
#endif
