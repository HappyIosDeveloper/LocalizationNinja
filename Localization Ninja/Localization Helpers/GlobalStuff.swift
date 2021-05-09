//
//  GlobalStuff.swift
//  Localization Ninja
//
//  Created by Ahmadreza on 5/9/21.
//

import UIKit

let defaultLanguage = Bundle.main.preferredLocalizations.first?.prefix(2) // MARK: Xcode runing language settings may effect on this variable.
var bundleKey: UInt8 = 0

enum UserDefaultKeys: String {
    case selectedAppLanguage
}

// MARK: in case you have to restart the app, it will trigger a notification so user could reopen the app easier
func restartApp() {
    let content = UNMutableNotificationContent()
    content.title = "Tap here"
    content.sound = UNNotificationSound.default
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
    exit(0)
}

func setDateFormat(to format: String) {
    var calendar = Calendar.current
    calendar.locale = Locale(identifier: format)
    let formatter = DateComponentsFormatter()
    formatter.calendar = calendar
}


class AnyLanguageBundle: Bundle {
    
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
              let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
