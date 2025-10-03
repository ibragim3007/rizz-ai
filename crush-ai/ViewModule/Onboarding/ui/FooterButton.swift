//
//  FooterBotton.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

extension OnboardingView {
    var footerButton: some View {
        VStack(spacing: 16) {
            PrimaryCTAButton(
                title: buttonTitle,
                isShimmering: !viewModel.isLast,
                fullWidth: true,
                action: onPrimaryButtonTap
            )
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
}
