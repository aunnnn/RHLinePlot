//
//  PressAndHorizontalDragGesture.swift
//  RHLinePlot
//
//  Created by Wirawit Rueopas on 4/18/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

/// A proxy view for press and horizontal drag detection.
public struct PressAndHorizontalDragGestureView: UIViewRepresentable {
    public let minimumPressDuration: Double
    public var onBegan: ((Value) -> Void)? = nil
    public var onChanged: ((Value) -> Void)? = nil
    public var onEnded: ((Value) -> Void)? = nil
    
    public struct Value {
        /// The location of the current event.
        public let location: CGPoint
    }
    
    public class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: PressAndHorizontalDragGestureView
        
        var isDraggingActivated: Bool = false
        
        var longPress: UILongPressGestureRecognizer!
        var pan: UIPanGestureRecognizer!
        
        init(parent: PressAndHorizontalDragGestureView) {
            self.parent = parent
        }

        public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            // Only on horizontal drag
            if gestureRecognizer == pan {
                // Long pressed already, allow any direction
                if isDraggingActivated {
                    return true
                }
                let v = pan.velocity(in: pan.view!)
                return abs(v.x) > abs(v.y)
            } else if gestureRecognizer == longPress {
                isDraggingActivated = true
                return true
            } else {
                fatalError("Unknown gesture recognizer")
            }
        }
        
        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            // Only this combo works together
            return (gestureRecognizer == pan && otherGestureRecognizer == longPress)
                || (gestureRecognizer == longPress && otherGestureRecognizer == pan)
        }

        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            // Assume ScrollView's internal pan gesture to be any UIPanGestureRecognizer
            return otherGestureRecognizer != pan && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let view = gesture.view else {
                assertionFailure("Missing view on gesture")
                return
            }
            
            // Must long press first
            guard isDraggingActivated else { return }
            switch gesture.state {
            case .changed:
                parent.onChanged?(.init(location: gesture.location(in: view)))
            default:
                break
            }
        }
        
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard let view = gesture.view else {
                assertionFailure("Missing view on gesture")
                return
            }
            switch gesture.state {
            case .began:
                isDraggingActivated = true
                parent.onBegan?(.init(location: gesture.location(in: view)))
            case .ended:
                isDraggingActivated = false
                parent.onEnded?(.init(location: gesture.location(in: view)))
            default: break
            }
        }
    }
    
    public func makeCoordinator() -> Self.Coordinator {
        return Coordinator(parent: self)
    }
    
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let longPress = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress))
        longPress.minimumPressDuration = minimumPressDuration
        longPress.delegate = context.coordinator
        
        view.addGestureRecognizer(longPress)
        context.coordinator.longPress = longPress
        
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan))
        pan.delegate = context.coordinator
        
        view.addGestureRecognizer(pan)
        context.coordinator.pan = pan
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView,
                             context: UIViewRepresentableContext<Self>) {
        // IMPORTANT: Must pass the new closures (onBegan etc.) to the Coordinator.
        // We do this just by passing self.
        // If not, those closures could capture invalid, old values.
        context.coordinator.parent = self
    }
}

