//
//  ShiftableViewController.swift
//  DropIn
//
//  Created by Kaden Oldham on 12/18/17.
//  Copyright © 2017 Kaden Oldham. All rights reserved.
//

import UIKit

class ShiftableViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    var currentYShiftForKeyboard: CGFloat = 0
    
    var textFieldBeingEdited: UITextField?
    var textViewBeingEdited: UITextView?
    
    var keyboardDismissTapGestureRecognizer: UITapGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboardDismissTapGestureRecognizer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        
    }
    @objc func stopEditingTextInput() {
        if let textField = self.textFieldBeingEdited {
            
            textField.resignFirstResponder()
            
            self.textFieldBeingEdited = nil
            self.textViewBeingEdited = nil
        } else if let textView = self.textViewBeingEdited {
            
            textView.resignFirstResponder()
            
            self.textFieldBeingEdited = nil
            self.textViewBeingEdited = nil
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldBeingEdited = textField
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textViewBeingEdited = textView
        return true
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        var keyboardSize: CGRect = .zero
        
        if let keyboardRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            keyboardRect.height != 0 {
            keyboardSize = keyboardRect
        } else if let keyboardRect = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect {
            keyboardSize = keyboardRect
        }
        
        if let textField = textFieldBeingEdited  {
            if self.view.frame.origin.y == 0 {
                
                let yShift = yShiftWhenKeyboardAppearsFor(textInput: textField, keyboardSize: keyboardSize, nextY: keyboardSize.height)
                self.currentYShiftForKeyboard = yShift
                self.view.frame.origin.y -= yShift
            }
        } else if let textView = textViewBeingEdited {
            if self.view.frame.origin.y == 0 {
                
                let yShift = yShiftWhenKeyboardAppearsFor(textInput: textView, keyboardSize: keyboardSize, nextY: keyboardSize.height)
                self.currentYShiftForKeyboard = yShift
                self.view.frame.origin.y -= yShift
            }
        }
    }
    
    @objc func yShiftWhenKeyboardAppearsFor(textInput: UIView, keyboardSize: CGRect, nextY: CGFloat) -> CGFloat {
        
        let textFieldOrigin = self.view.convert(textInput.frame, from: textInput.superview!).origin.y
        let textFieldBottomY = textFieldOrigin + textInput.frame.size.height
        
        // This is the y point that the textField’s bottom can be at before it gets covered by the keyboard
        let maximumY = self.view.frame.height - (keyboardSize.height + view.safeAreaInsets.bottom)
        
        if textFieldBottomY > maximumY {
            // This makes the view shift the right amount to have the text field being edited just above they keyboard if it would have been covered by the keyboard.
            return textFieldBottomY - maximumY
        } else {
            // It would go off the screen if moved, and it won’t be obscured by the keyboard.
            return 0
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        if self.view.frame.origin.y != 0 {
            
            self.view.frame.origin.y += currentYShiftForKeyboard
        }
        
        stopEditingTextInput()
    }
    
    @objc func setupKeyboardDismissTapGestureRecognizer() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(stopEditingTextInput))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
        keyboardDismissTapGestureRecognizer = tapGestureRecognizer
        
    }
}
