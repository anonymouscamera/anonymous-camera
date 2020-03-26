//
//  ACScene.swift
//  anonymous-camera
//
//  Created by Aaron Abentheuer on 26/03/2020.
//  Copyright © 2020 Aaron Abentheuer. All rights reserved.
//

import SwiftUI
import UIKit

final public class ACScene : ObservableObject {
    @Published public var sceneIsActive : Bool = false
    
    @Published public var deviceOrientation : UIDeviceOrientation = UIDevice.current.orientation {
        didSet {
            if !(deviceOrientation == .faceDown || deviceOrientation == .faceUp || deviceOrientation == .portraitUpsideDown || deviceOrientation == .unknown) {
                if oldValue.isLandscape {
                    devicePreviousOrientationWasLandscape = true
                } else {
                    devicePreviousOrientationWasLandscape = false
                }
                
                if !deviceOrientation.isLandscape {
                    ACAnonymisation.shared.interviewModeConfiguration = .off
                }
                
                if deviceOrientation == .landscapeLeft {
                    deviceRotationAngle = Angle(degrees: 90)
                    deviceLandscapeRotationAngle = Angle(degrees: 90)
                } else if deviceOrientation == .landscapeRight {
                    deviceRotationAngle = Angle(degrees: -90)
                    deviceLandscapeRotationAngle = Angle(degrees: -90)
                } else {
                    deviceRotationAngle = Angle(degrees: 0)
                }
            }
        }
    }
    @Published public var deviceRotationAngle : Angle = Angle(degrees: 0)
    @Published public var deviceLandscapeRotationAngle : Angle = Angle(degrees: 90)
    @Published public var devicePreviousOrientationWasLandscape : Bool = false

    @Published public var interviewModeControlIsHoveringOverClose : Bool = false
    static var shared = ACScene()
}