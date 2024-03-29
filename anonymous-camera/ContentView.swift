//
//  ContentView.swift
//  anonymous-camera
//
//  Created by Aaron Abentheuer on 17/03/2020.
//  Copyright © 2020 Aaron Abentheuer. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var sceneInformation : ACScene
    @EnvironmentObject var anonymisation : ACAnonymisation
    
    @State var dragOffset : CGSize = CGSize.zero
    @State var bottomSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            VStack {
                if (!sceneInformation.isVideoRecording && UIScreen.current > ScreenType.iPhone4_7) {
                    
                    HStack (spacing: 8) {
                        ACQuickSetting(isOn: $anonymisation.exifLocation, icon: Image("AC_PRIVACY_LOCATION"))
                            .rotationEffect(self.sceneInformation.bottomSheetIsOpen ? Angle(degrees: 0) : sceneInformation.deviceRotationAngle)
                            .animation(Animation.interactiveSpring(response: 0.32, dampingFraction: 0.8, blendDuration: 0))
                        
                        ACQuickSetting(isOn: $anonymisation.exifDateTime, icon: Image("AC_PRIVACY_TIMESTAMP"))
                            .rotationEffect(self.sceneInformation.bottomSheetIsOpen ? Angle(degrees: 0) : sceneInformation.deviceRotationAngle)
                            .animation(Animation.interactiveSpring(response: 0.32, dampingFraction: 0.8, blendDuration: 0))
                    }
                    .saturation((self.sceneInformation.isDraggingBottomSheet || self.sceneInformation.bottomSheetIsOpen) ? 0 : 1)
                    .transition(AnyTransition.opacity.combined(with: AnyTransition.scale(scale: 0.9)))
                } else {
                    if (UIScreen.current > ScreenType.iPhone4_7) {
                        Spacer()
                    }
                }
                
                ACViewfinder()
                ChildSizeReader(size: $bottomSize) {
                    Spacer()
                }
            }
            .background(
                Color.black
                    .edgesIgnoringSafeArea(.all)
            )
            
            Rectangle()
                .foregroundColor((self.sceneInformation.bottomSheetIsOpen) ? Color.white.opacity(0.12) : Color.clear)
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(self.sceneInformation.bottomSheetIsOpen ? true : false)
                .animation(Animation.easeInOut)
                .onTapGesture {
                    self.sceneInformation.bottomSheetIsOpen.toggle()
            }
            GeometryReader { geometry in
                if (!self.sceneInformation.isVideoRecording) {
                    BottomSheetView(
                        maxHeight: geometry.size.height*0.75,
                        minHeight: self.bottomSize.height
                    ) {
                        Spacer()
                    }
                    .transition(AnyTransition.opacity.combined(with: AnyTransition.move(edge: .bottom)))
                }
                
            }
            .edgesIgnoringSafeArea(.all)
            .zIndex(100)
        }
    }
}

struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize
    let content: () -> Content
    var body: some View {
        ZStack {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: SizePreferenceKey.self, value: proxy.size)
                    }
            )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero
    
    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}

struct ACQuickSetting : View {
    
    @Binding var isOn : Bool
    @State var isBeingTouched : Bool = false
    var icon : Image
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(Color.white.opacity(0.12))
                    .frame(width: 40, height: 40)
                    .padding(6)
                
                icon.resizable()
                    .frame(width: 28, height: 28)
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(Color.white)
                    .opacity(isOn ? 1 : 0.36)
                
                VStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .foregroundColor(self.isOn ? Color.clear : Color("highlight"))
                        .frame(maxHeight: self.isOn ? 2 : 200, alignment: .center)
                        .animation(Animation.interactiveSpring(response: 0.32, dampingFraction: 0.72, blendDuration: 0))
                }
                .background(Color.clear)
                .frame(width: 2, height: 48, alignment: .top)
                .rotationEffect(Angle(degrees: -45))
            }
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded({ _ in
                    self.isOn.toggle()
                })
        )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        withAnimation(.easeOut(duration: 0.08)) {
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

struct ACViewfinder: View {
    
    @EnvironmentObject var sceneInformation : ACScene
    @EnvironmentObject var anonymisation : ACAnonymisation
        
    internal var threeByFourAspectRatio : CGFloat = 3.0/4.0
    internal var sixteenByNineAspectRatio : CGFloat = 9.0/16.0
    
    var body: some View {
        ZStack {
                ACViewfinderCard()

        }
    }
}

struct ACViewfinderCard : View {
    @EnvironmentObject var sceneInformation : ACScene
    @EnvironmentObject var anonymisation : ACAnonymisation
    
    @State internal var shutterPosition : CGPoint = CGPoint.zero
    @GestureState var isLongPressed : Bool = false
    
    @State internal var viewFinderFrame : CGRect = CGRect.zero
    
    internal var threeByFourAspectRatio : CGFloat = 3.0/4.0
    internal var sixteenByNineAspectRatio : CGFloat = 9.0/16.0
    
    @State internal var flash : Bool = false
    @State internal var knobIsHoveringOverLockArea : Bool = false
    @State internal var lockedRecording : Bool = false
    
    var body : some View {
        ZStack {
                ZStack {
                    ACViewfinderView()
                        .background(
                            GeometryReader { geometry in
                            Spacer()
                                .preference(key: FramePreferenceKey.self, value: geometry.frame(in: .local))
                                .onPreferenceChange(FramePreferenceKey.self) { value in
                                    print("new frame: \(value)")
                                    viewFinderFrame = value
                                }
                            }
                        )
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .overlay(RadialGradient(gradient: Gradient(colors: [Color.white.opacity(0.68), Color.white.opacity(1)]), center: UnitPoint(x: 0.5, y: 0.5), startRadius: 0, endRadius: self.viewFinderFrame.height/2))
                        .opacity(self.flash ? 1 : 0)

                    ZStack {
                        ForEach(self.anonymisation.faces) { (face) in
                            if !(self.anonymisation.selectedFilter?.filterType.modifiesImage ?? false) {
                                ACFaceRectangle()
                                    .transition(AnyTransition.scale(scale: 0.75).combined(with: AnyTransition.opacity))
                                    .frame(width: face.rect.width, height: face.rect.height, alignment: .center)
                                    .position(CGPoint(x: face.rect.minX, y: face.rect.minY))
                                    .animation(Animation.interactiveSpring())
                            }
                        }
                    }
                    .animation(Animation.interactiveSpring(response: 0.32, dampingFraction: 0.72, blendDuration: 0))
                    
                    VStack {
                        if self.sceneInformation.showHUD {
                            HStack {
                                ACHuD()
                            }
                            .padding()
                            .transition(AnyTransition.opacity.combined(with: AnyTransition.move(edge: .top)))
                        }
                        Spacer()
                    }
                    .frame(maxWidth: self.sceneInformation.deviceOrientation.isLandscape ? self.viewFinderFrame.height : self.viewFinderFrame.width, maxHeight: self.sceneInformation.deviceOrientation.isLandscape ? self.viewFinderFrame.width : self.viewFinderFrame.height)
                    .rotationEffect(self.sceneInformation.deviceRotationAngle)
                    
                    ACShutterLockArea(hovering: self.$knobIsHoveringOverLockArea, locked: self.$lockedRecording)
                        .position(CGPoint(x: self.viewFinderFrame.width/2, y: self.viewFinderFrame.height-(70/2)-24))
                    
                    ACShutterKnob(locked: self.$lockedRecording)
                        .position(self.sceneInformation.isVideoRecording && !self.lockedRecording ? self.shutterPosition : CGPoint(x: self.viewFinderFrame.width/2, y: self.viewFinderFrame.height-(70/2)-24))
                        .animation(self.sceneInformation.isVideoRecording ? Animation.interactiveSpring() : Animation.spring())
                        .onTapGesture {
                            if !self.sceneInformation.isVideoRecording {
                                ACAnonymisation.shared.takePhoto()
                                
                                withAnimation(Animation.interactiveSpring()) {
                                    self.flash = true
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                    withAnimation(Animation.spring()) {
                                        self.flash = false
                                    }
                                }
                            } else {
                                self.sceneInformation.isVideoRecording = false
                            }
                            
                            if self.lockedRecording {
                                withAnimation(Animation.spring()) {
                                    ACAnonymisation.shared.finishRecording()
                                }
                                self.lockedRecording = false
                                self.sceneInformation.isVideoRecording = false
                            }
                        }
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.3, maximumDistance: CGFloat.infinity)
                                .onEnded({ _ in
                                    print("start recording")
                                    
                                    self.sceneInformation.isVideoRecording = true
                                    
                                    withAnimation(Animation.spring()) {
                                        ACAnonymisation.shared.startRecording()
                                    }
                                })
                    )
                            
                    ACRotationAccessoryButton(icon: UIImage(named: "AC_SWITCH_CAMERA")!)
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded({ _ in
                                    ACAnonymisation.shared.toggleFrontAndBackCamera()
                                })
                    )
                        .opacity(self.sceneInformation.isVideoRecording ? 0 : 1)
                        .position(CGPoint(x: self.viewFinderFrame.width*0.75, y: self.viewFinderFrame.height-(70/2)-24))

                }
                .aspectRatio(self.sceneInformation.isVideoRecording ? self.sixteenByNineAspectRatio : self.threeByFourAspectRatio, contentMode: .fit)
                .foregroundColor(Color(UIColor.darkGray))
                .blur(radius: self.sceneInformation.sceneIsActive && Anon.isRunning ? 0 : 60)
                .blur(radius: self.sceneInformation.isDraggingBottomSheet || self.sceneInformation.bottomSheetIsOpen ? 28 : 0)
                .saturation(self.sceneInformation.isDraggingBottomSheet || self.sceneInformation.bottomSheetIsOpen ? 0 : 1)
                .overlay(
                    ZStack {
                        
                        ZStack {
                                ACViewfinderLandscapeContainer()
                                    .frame(width: viewFinderFrame.height, height: viewFinderFrame.width, alignment: .center)
                                    .rotationEffect(self.sceneInformation.deviceLandscapeRotationAngle)
                                    .animation(self.sceneInformation.devicePreviousOrientationWasLandscape ? (Animation.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) : nil, value: self.sceneInformation.deviceLandscapeRotationAngle)
                                    .opacity(self.sceneInformation.interviewModeAvailable ? 1 : 0)
                        }
                        .padding()

                        
                        RoundedRectangle(cornerRadius: (UIScreen.current > ScreenType.iPhone4_7) ? 12 : (self.sceneInformation.isDraggingBottomSheet || self.sceneInformation.bottomSheetIsOpen) ? 4 : 0, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 2)
                        if !self.sceneInformation.sceneIsActive {
                            ZStack {
                                Circle()
                                    .frame(width: 64, height: 64, alignment: .center)
                                    .foregroundColor(Color.white.opacity(0.25))
                                Image(systemName: "eye.slash.fill")
                                    .font(.system(size: 21.0, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .transition(AnyTransition.scale(scale: 0.5).combined(with: AnyTransition.opacity))
                        }
                    }
                )
                    .clipShape(
                        RoundedRectangle(cornerRadius: (UIScreen.current > ScreenType.iPhone4_7) ? 12 : (self.sceneInformation.isDraggingBottomSheet || self.sceneInformation.bottomSheetIsOpen) ? 4 : 0, style: .continuous)
                )
                .simultaneousGesture(
                        
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged({ value in
                                
                                self.shutterPosition = value.location
                                
                                if self.sceneInformation.isVideoRecording {
                                    
                                    if self.shutterPosition.y + 35 >= self.viewFinderFrame.height-70 {
                                        self.knobIsHoveringOverLockArea = true
                                    } else {
                                        self.knobIsHoveringOverLockArea = false
                                    }
                                }
                            
                            })
                            .onEnded({ value in
                                
                                if self.sceneInformation.isVideoRecording {
                                    if self.knobIsHoveringOverLockArea {
                                        self.lockedRecording = true
                                        
                                    } else {
                                        withAnimation(Animation.spring()) {
                                            self.sceneInformation.isVideoRecording = false
                                        }
                                        ACAnonymisation.shared.finishRecording()
                                    }
                                }
                                

                            })
                )
                    .padding(0)
                    .scaleEffect(
                        (!self.sceneInformation.sceneIsActive || self.sceneInformation.isDraggingBottomSheet || self.sceneInformation.bottomSheetIsOpen) ? 0.94 : 1
                )
                    .animation(Animation.spring())
        }
    }
}

struct ACRotationAccessoryButton : View {
    
    var icon : UIImage
    @EnvironmentObject var sceneInformation : ACScene
    @EnvironmentObject var anonymisation : ACAnonymisation
    @State var isBeingTouched : Bool = false
    
    var body : some View {
        ZStack {
            Rectangle()
                .clipShape(
                    Circle()
            )
                .foregroundColor(Color.white.opacity(self.isBeingTouched ? 0.36 : 0.12))
                .scaleEffect(self.isBeingTouched ? 1.2 : 1)
                .frame(width: 56, height: 56, alignment: .center)
            
            Image(uiImage: icon)
                .resizable()
                .rotationEffect(Angle(degrees: self.isBeingTouched ? (anonymisation.cameraFacingFront ? 24 : -24) : 0))
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundColor(Color.white)
        }
        .rotationEffect(
            withAnimation(Animation.interactiveSpring(response: 0.32, dampingFraction: 0.6, blendDuration: 0), {
                Angle(degrees: anonymisation.cameraFacingFront ? 180 : 0)
            })
        )
            .rotationEffect(sceneInformation.deviceRotationAngle)
            .shadow(color: Color.black.opacity(0.24), radius: 12, x: 0, y: 0)
            .animation(Animation.interactiveSpring(response: 0.32, dampingFraction: 0.6, blendDuration: 0))
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        withAnimation(.easeOut(duration: 0.08)) {
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

struct ACFaceRectangle : View {
    
    @State var isBeingTouched : Bool = false
    @EnvironmentObject var anonymisation : ACAnonymisation
    
    @State var faceRectangle : CGRect = .zero
    
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Rectangle()
                    .foregroundColor(Color.white.opacity(0.18))
                    .preference(key: FramePreferenceKey.self, value: geometry.frame(in: .global))
                    .onPreferenceChange(FramePreferenceKey.self) { value in
                        faceRectangle = value
                        print(faceRectangle.height)
                    }
            }
        }
        .clipShape(
            RoundedRectangle(cornerRadius: faceRectangle.height*0.125, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: faceRectangle.height*0.25, style: .continuous)
                .foregroundColor(.clear)
                .stroke(color: Color(UIColor(named: "highlight")?.withAlphaComponent(1) ?? .clear), lineWidth: 2, cornerPercentage: 0.25, style: .automatic)
        )
        .opacity(self.anonymisation.selectedFilterGroup.filters[self.anonymisation.selectedFilterGroup.selectedFilterIndex].filterType.modifiesImage ? 0 : 1)
        .scaleEffect(isBeingTouched ? 0.9 : 1)
        .shadow(color: Color(UIColor(named: "highlight")?.withAlphaComponent(0.25) ?? .clear), radius: 24, x: 0, y: 0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in
                    withAnimation(.easeOut(duration: 0.08)) {
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

struct ACViewfinderLandscapeContainer: View {
    
    @EnvironmentObject var anonymisation : ACAnonymisation
    @EnvironmentObject var sceneInformation : ACScene
    
    var body: some View {
        ZStack {
            ACInterviewModeContainerView(interviewModeIsOn: anonymisation.interviewModeIsOn, orientation: sceneInformation.deviceOrientation, interviewModeConfiguration: anonymisation.interviewModeConfiguration, selectedFilter: anonymisation.selectedFilterGroup.filters[anonymisation.selectedFilterGroup.selectedFilterIndex], interviewModeControlIsBeingPanned: sceneInformation.interviewModeControlIsBeingTouched)
        }
    }
}
