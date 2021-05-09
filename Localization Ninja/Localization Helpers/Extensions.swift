//
//  StringExtension.swift
//  Localization Ninja
//
//  Created by Ahmadreza on 5/9/21.
//

import UIKit

extension String {
    
    func localized(bundle:Bundle = .main, tableName:String = "Localization") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "\(self)", comment: "")
    }
    
    func localize(with arguments: CVarArg...) -> String {
        let args = arguments.map {
            if let arg = $0 as? Int { return String(arg) }
            if let arg = $0 as? Float { return String(arg) }
            if let arg = $0 as? Double { return String(arg) }
            if let arg = $0 as? Int64 { return String(arg) }
            if let arg = $0 as? String { return String(arg) }
            return "(null)"
        } as [CVarArg]
        return String.init(format: self.localized(), arguments: args)
    }
    
    var isFarsi: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "(?s).*\\p{Arabic}.*")
        return predicate.evaluate(with: self)
    }
}

extension NumberFormatter {

    static let moneyFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.generatesDecimalNumbers = true
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 2
        nf.numberStyle = .decimal
        return nf
    }()

    static func resetupCashed() {
        moneyFormatter.locale = Locale.current
    }
}


extension DateFormatter {

    static let dobFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .full
        return df
    }()

    static func resetupCashed() {
        dobFormatter.locale = Locale.current
    }
}

extension UIView {
    
    func handleDirection(isRightToLeft: Bool) {
        semanticContentAttribute = isRightToLeft ? .forceRightToLeft : .forceLeftToRight
    }
    
    func flipHorizontally() {
        transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    
    func forceDirectionForAllLabels(to direction: NSTextAlignment) {
        let labels = subviews(ofType: UILabel.self)
        labels.filter({$0.tag != 222}).forEach({$0.textAlignment = direction}) // MARK: Ignores the lables tagged with 222
    }
    
    func subviews<T:UIView>(ofType WhatType:T.Type) -> [T] {
        var result = self.subviews.compactMap {$0 as? T}
        for sub in self.subviews {
            result.append(contentsOf: sub.subviews(ofType:WhatType))
        }
        return result
    }
}
