//
//  ErrorView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 24/4/25.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(Color.appRed)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.appText)

            Button("Retry", action: retryAction)
                .padding()
                .background(Color.appAccent)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
        .background(Color.appBackground)
    }
}
