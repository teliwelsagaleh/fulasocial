//
//  AvatarView.swift
//  Social Platform
//

import SwiftUI

struct AvatarView: View {
    let name: String
    var size: CGFloat = 40
    var imageURL: String? = nil

    var body: some View {
        Circle()
            .fill(Color.blue.gradient)
            .frame(width: size, height: size)
            .overlay {
                Text(name.prefix(1).uppercased())
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundStyle(.white)
            }
    }
}

#Preview {
    HStack(spacing: 16) {
        AvatarView(name: "John", size: 32)
        AvatarView(name: "Alice", size: 48)
        AvatarView(name: "Bob", size: 64)
    }
}
