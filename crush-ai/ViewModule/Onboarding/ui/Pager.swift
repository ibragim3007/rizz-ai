//
//  Pager.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct OnboardingPager: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        TabView(selection: $viewModel.currentIndex) {
            ForEach(viewModel.steps.indices, id: \.self) { index in
                OnboardingStepView(viewModel: viewModel, kind: viewModel.steps[index].kind, illustration: viewModel.steps[index].illustration)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Перехватываем свайпы, чтобы TabView не листался жестами
        .highPriorityGesture(DragGesture())
    }
    
}
