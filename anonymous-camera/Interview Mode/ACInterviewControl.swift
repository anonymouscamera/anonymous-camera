//
//  ACInterviewControl.swift
//  anonymous-camera
//
//  Created by Aaron Abentheuer on 20/03/2020.
//  Copyright © 2020 Aaron Abentheuer. All rights reserved.
//

import SwiftUI

struct ACInterviewControl: View {
    
    @EnvironmentObject var sceneInformation : ACScene
    @EnvironmentObject var anonymisation : ACAnonymisation
    
    @State internal var isBeingTouched : Bool = false
    
    var body: some View {
        HStack (alignment: .center) {
            
            Image(uiImage: UIImage(named: "AC_FILTER_NONE_ICON")!)
                .foregroundColor(Color.black)
                .rotationEffect(self.anonymisation.interviewModeEffectsSwitched ? Angle(degrees: 180) : Angle(degrees: 0))
            
            if !self.anonymisation.interviewModeIsOn {
                Text("Interview")
                    .font(Font.system(size: 14, weight: .semibold, design: .default))
                    .transition(AnyTransition.scale(scale: 0.75, anchor: UnitPoint(x: 0.5, y: 0.5)).combined(with: AnyTransition.opacity))
            }
            
            
            VStack {
                if self.anonymisation.selectedFilter?.filterIdentifier == "AC_FILTER_PIXEL" {
                    Image(uiImage: UIImage(named: "AC_FILTER_PIXEL_ICON")!)
                        .foregroundColor(Color.black)
                        .rotationEffect(self.anonymisation.interviewModeEffectsSwitched ? Angle(degrees: 180) : Angle(degrees: 0))
                } else  {
                    Image(uiImage: UIImage(named: "AC_FILTER_BLUR_ICON")!)
                        .foregroundColor(Color.black)
                        .rotationEffect(self.anonymisation.interviewModeEffectsSwitched ? Angle(degrees: 180) : Angle(degrees: 0))
                }
            }
        }
        .rotationEffect(self.anonymisation.interviewModeEffectsSwitched ? Angle(degrees: 180) : Angle(degrees: 0))
        .padding()
        .background(Blur(style: .systemChromeMaterialLight))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .scaleEffect(self.isBeingTouched ? 0.9 : 1)
        .offset(y: self.sceneInformation.deviceOrientation.isLandscape ? 0 : 200)
        .shadow(color: Color(UIColor.black.withAlphaComponent(self.anonymisation.interviewModeIsOn ? 0.24 : 0.12)), radius: 18, x: 0, y: 0)
        .animation(Animation.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: self.sceneInformation.deviceOrientation.isLandscape)
        .animation(Animation.interactiveSpring(response: 0.4, dampingFraction: 0.6, blendDuration: 0), value: self.anonymisation.interviewModeIsOn)
        .simultaneousGesture(
            TapGesture()
                .onEnded({ _ in
                    if self.anonymisation.interviewModeIsOn {
                        withAnimation(Animation.interactiveSpring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                            self.anonymisation.switchEffectsInInterviewMode()
                        }
                    } else {
                        self.anonymisation.interviewModeConfiguration = .effectLeading
                    }
                })
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("landscapeContainer"))
                .onChanged({ value in
                    withAnimation(.easeOut(duration: 0.12)) {
                        self.isBeingTouched = true
                    }
                })
                .onEnded({ _ in
                    withAnimation(.easeOut(duration: 0.24)) {
                        self.isBeingTouched = false
                    }
                })
        )
    }
}