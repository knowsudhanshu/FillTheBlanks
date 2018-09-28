//
//  ViewController.swift
//  FillTheBlanks
//
//  Created by Sudhanshu Sudhanshu on 18/09/18.
//  Copyright © 2018 Sudhanshu Sudhanshu. All rights reserved.
//

import UIKit

let blankSpaceHolder: String = "____"

class ViewController: UIViewController {

    var blankTag: String = "_"
    var blankDict: [String: Any] = [:] // To keep track of location and range of blank fields
    var mutableRanges: [NSRange] = []
    var changingRange: NSRange?
    
    var answers: [String] = []
    
    let textView: LWTextView = {
        let textView = LWTextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "I thought it was important to \(blankSpaceHolder) but now I think its more \(blankSpaceHolder) important to 📷"
        textView.backgroundColor = .red
        return textView
    }()
    
    var keyboardHeight: CGFloat = 0.0
    
    var textViewBottomConstraint : NSLayoutConstraint?
    
    var sparkAnswerTextColor : UIColor = .black
    var sparkAnswerBlankBackgroundColor: UIColor = UIColor.groupTableViewBackground
    
    @objc func tapGHandler() {
        view.endEditing(true)
    }
    
    func setupKeyBoardNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @objc
    func keyboardWillShow(_ notification: Notification) {
        
        let userInfo = (notification as NSNotification).userInfo;
        let keyboardFrame = (userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if keyboardFrame.height > self.keyboardHeight {
            
            let yMovement = keyboardFrame.height
            self.textViewBottomConstraint?.constant = -yMovement
            self.keyboardHeight = yMovement
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: Notification) {
        
        self.textViewBottomConstraint?.constant = -240

        self.keyboardHeight = 0.0
        self.view.layoutIfNeeded()
        
    }
    
    func addConstraints(to subView: UIView) {
        view.addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = NSLayoutConstraint.init(item: subView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 40)
        let leftContraint = NSLayoutConstraint(item: subView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 20)
        
        let rightContraint = NSLayoutConstraint(item: subView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -20)
        
        textViewBottomConstraint = NSLayoutConstraint(item: subView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -240)
        
        let constraints = [topConstraint, leftContraint, rightContraint, textViewBottomConstraint!]
        NSLayoutConstraint.activate(constraints)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textView.delegate = self
        addConstraints(to: textView)
        
        setupKeyBoardNotification()
        
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapGHandler)))
        updateBlankRange()
    }
    
    
    func updateBlankRange() {
        let textRange = NSMakeRange(0, textView.text.count)
        let expression = try! NSRegularExpression(pattern: "\(blankSpaceHolder)", options: NSRegularExpression.Options())
        let array = expression.matches(in: textView.text, options: .reportProgress, range: textRange)
        for res in array {
            let range = res.range
            self.mutableRanges.append(range)
            self.blankDict["\(range.location)"] = self.mutableRanges.count - 1
            
            let foregroundColor : UIColor = sparkAnswerTextColor
            let backgroundColor : UIColor = sparkAnswerBlankBackgroundColor
            
            let attributes = [
                .foregroundColor: foregroundColor,
                .backgroundColor: backgroundColor,
                .font:  UIFont.boldSystemFont(ofSize: 17),
                NSAttributedStringKey.init(rawValue: "blank"): "blank"
                ] as [NSAttributedStringKey : Any]
            
            textView.textStorage.addAttributes(attributes, range: range)
        }
        textView.mutableRanges = mutableRanges
    }
    
//    func allBlankFields() -> [NSRange] {
//        let textRange = NSMakeRange(0, textView.text.count)
//        let expression = try! NSRegularExpression(pattern: "\(blankTag)", options: NSRegularExpression.Options())
//        let array = expression.matches(in: textView.text, options: .reportProgress, range: textRange)
//        for res in array {
//            self.mutableRanges.append(res.range)
//        }
//        return array
//    }
}


extension ViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        if let firstRange = mutableRanges.first {
//            textView.selectedRange = firstRange
//            return true
//        }
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
//        if mutableRanges.contains(range) {
//            return true
//        }
        
        let cursorPosition = textView.selectedRange

//        for mutableRange in mutableRanges {
        let tempRangeArr = mutableRanges
        for i in 0 ..< tempRangeArr.count {
            var mutableRange = mutableRanges[i]
            if cursorPosition.location >= mutableRange.location /*&& cursorPosition.location < (mutableRange.location + mutableRange.length)*/ {
                print("Should be editing in range")
                print("cursorPosition: \(cursorPosition)")
               
                if let textRange = range.toTextRange(textInput: textView) {
                    
                    if text.isEmpty {
                        textView.replace(textRange, withText: text)
                        mutableRange.length = mutableRange.length - range.length
                        if mutableRange.length <= 0 {
                            textView.replace(textRange, withText: blankSpaceHolder)
                        }
                        mutableRanges[i] = mutableRange
                    }else {
                        textView.replace(textRange, withText: text)
                        let text = textView.text(in: textRange)
                        if text == blankSpaceHolder {
                            mutableRange.length =  range.length
                        }else {
                            mutableRange.length =  mutableRange.length + range.length
                        }
                        
                        mutableRanges[i] = mutableRange
                    }
                    
                }
                
                
                updateBlankRange()
                return false
            }else {
                continue
//                textView.isEditable = false
//                textView.resignFirstResponder()
//                return false
            }
            
            
//            let changingRange = textView.selectedRange
//            print("changingRange: \(changingRange)")
//            let overlap = NSIntersectionRange(changingRange, range)
//            print("overlap: \(overlap)")
//            if /*overlap.location != 0 || */overlap.length != 0 {
//                return true // the ranges overlap
//            }
        }
        return false
    }
}
extension NSRange {
    func toTextRange(textInput:UITextInput) -> UITextRange? {
        
        if let rangeStart = textInput.position(from: textInput.beginningOfDocument, offset: location), let rangeEnd = textInput.position(from: rangeStart, offset: length){
            return textInput.textRange(from: rangeStart, to: rangeEnd)
        }
        return nil
    }
}

class LWTextView: UITextView  {
    
    var mutableRanges: [NSRange] = []
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
          return
        }
        super.addGestureRecognizer(gestureRecognizer)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.delaysContentTouches = false
        // required for tap to pass through on to superview & for links to work
        self.isScrollEnabled = false
        self.isEditable = false
        self.isUserInteractionEnabled = true
        self.isSelectable = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // location of the tap
        var location = point
        location.x -= self.textContainerInset.left
        location.y -= self.textContainerInset.top
        
        // find the character that's been tapped
        let characterIndex = self.layoutManager.characterIndex(for: location, in: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if characterIndex < self.textStorage.length {
            
//            if (self.textStorage.attribute(NSAttributedStringKey(rawValue: "blank"), at: characterIndex, effectiveRange: nil) != nil) {
            if (self.textStorage.attribute(.backgroundColor, at: characterIndex, effectiveRange: nil) != nil) {

                self.isEditable = true
                self.becomeFirstResponder()
                
                for mutableRange in mutableRanges {
                    
                    if characterIndex >= mutableRange.location && characterIndex <= (mutableRange.location + mutableRange.length) {
                        self.selectedRange = mutableRange
//                        return true
                    }else {
//                        textView.isEditable = false
//                        textView.resignFirstResponder()
//                        return false
                    }
                }
                
                
                
                
                return self
            }
        }
        self.isEditable = false
        self.resignFirstResponder()
        // otherwise return nil so the tap goes on to the next receiver
        return nil
    }
    
}
