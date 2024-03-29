//
//  ACCloseInterviewModeControl.swift
//  anonymous-camera
//
//  Created by Aaron Abentheuer on 26/03/2020.
//  Copyright © 2020 Aaron Abentheuer. All rights reserved.
//

import SwiftUI

struct ACCloseInterviewModeControl: View {
    
    @EnvironmentObject var sceneInformation : ACScene
    @EnvironmentObject var anonymisation : ACAnonymisation
    
    @State var highlighted : Bool = false
    
    var body: some View {
        ZStack {
            if anonymisation.interviewModeIsOn {
                HStack {
                    Image("xmark")
                }
                .padding(8)
                .background(sceneInformation.interviewModeControlIsHoveringOverClose ? Blur(style: .systemChromeMaterialDark) : Blur(style: .systemThinMaterialDark))
                .cornerRadius(percentage: 1, style: .circular)
                .scaleEffect(sceneInformation.interviewModeControlIsHoveringOverClose ? 1.2 : 1)
                .scaleEffect(highlighted ? 1.2 : 1)
                .animation(Animation.interactiveSpring(response: 0.32, dampingFraction: 0.72, blendDuration: 0))
            }
        }
        .environmentObject(anonymisation)
        .environmentObject(sceneInformation)
        .offset(y: self.sceneInformation.deviceOrientation.isLandscape ? 0 : 200)
        .animation(Animation.interactiveSpring(response: 0.32, dampingFraction: 0.72, blendDuration: 0))
        .transition(.scale(scale: 0.5))
        .onTapGesture {
            self.anonymisation.interviewModeConfiguration = .off
            self.highlighted = false

        }

    }
}

struct ACCloseInterviewModeControl_Previews: PreviewProvider {
    static var previews: some View {
        ACCloseInterviewModeControl()
    }
}
