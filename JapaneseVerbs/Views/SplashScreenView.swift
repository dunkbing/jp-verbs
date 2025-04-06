//
//  SplashScreenView.swift
//  JapaneseVerbs
//
//  Created by Bùi Đặng Bình on 7/4/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var showTitle = false
    @State private var showIcon = false
    @State private var showSubtitle = false

    var onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.appBackground.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                if showIcon {
                    Image(systemName: "character.book.closed.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color.appAccent)
                        .scaleEffect(isAnimating ? 1.0 : 0.6)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isAnimating)
                }

                if showTitle {
                    Text("Japanese Verbs")
                        .font(.system(.title, design: .rounded))
                        .bold()
                        .foregroundColor(Color.appText)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .blur(radius: isAnimating ? 0 : 5)
                        .animation(.easeInOut(duration: 0.8), value: isAnimating)
                }

                if showSubtitle {
                    Text("Learn and master Japanese verbs")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appSurface.opacity(showIcon ? 0.8 : 0))
                    .animation(.easeIn(duration: 0.5), value: showIcon)
            )
            .shadow(color: Color.appText.opacity(0.1), radius: 10)
        }
        .onAppear {
            animateSplash()
        }
    }

    private func animateSplash() {
        // First show the icon
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showIcon = true

            // Then animate it
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = true

                // Show title after icon animation starts
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showTitle = true

                    // Show subtitle after title
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showSubtitle = true

                        // Finally, finish the splash screen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            onFinished()
                        }
                    }
                }
            }
        }
    }
}
