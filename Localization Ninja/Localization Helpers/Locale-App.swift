//
//  Locale-App.swift
//  Radiant Tap Essentials
//
//  Copyright © 2016 Aleksandar Vacić, Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

final class AppLocale {
	fileprivate(set) var original: Locale
	fileprivate(set) var originalPreferredLanguages: [String]
	private init() {
		original = Locale.current
		originalPreferredLanguages = Locale.preferredLanguages
	}
	static var shared = AppLocale()


	///	Builds as specific LocaleIdentifier as your app needs
	private var localeIdentifier: String {
		//	start with whatever was the iOS original
		var comps = NSLocale.components(fromLocaleIdentifier: original.identifier)

		//	Note: if customer has not yet chosen anything custom,
		//	then it may make sense to default to primary language on his device

		//	then load your app-level overrides
//		for (key, value) in AppConfig.localeOverrides {
//			comps[key] = value
//		}

		//	then potentially load customer-account-level overrides (from say back-end API)
//		for (key, value) in Customer.localeOverrides {
//			comps[key] = value
//		}

		//	then override the language with current in-app choice
		if let languageCode = UserDefaults.languageCode {
			comps[NSLocale.Key.languageCode.rawValue] = languageCode
		}

		if let regionCode = UserDefaults.regionCode ?? original.regionCode {
			comps[NSLocale.Key.countryCode.rawValue] = regionCode
		}

		//	WARNING:
		//	user language must be one of the ones available in the app
		//	so make sure that whatever ends up as result, it actually has its own .lproj file
		//	this is good moment to make sanity checks

		//	finally return all of those settings combined
		let identifier = NSLocale.localeIdentifier(fromComponents: comps)
		return identifier
	}

	class var identifier: String { return shared.localeIdentifier }
}

extension NSLocale {

	///	This is used to override `current`. It uses `AppLocale.identifier`
	@objc class var app: Locale {
		return Locale(identifier: AppLocale.identifier)
	}

	@objc class var appPreferredLanguages: [String] {
		var arr = AppLocale.shared.originalPreferredLanguages
		if let languageCode = UserDefaults.languageCode, !arr.contains(languageCode) {
			arr.insert(languageCode, at: 0)
		}
		return arr
	}

	fileprivate static func swizzle(selector: Selector, with replacement: Selector) {
		let originalSelector = selector
		let swizzledSelector = replacement
		guard
			let originalMethod = class_getClassMethod(self, originalSelector),
			let swizzledMethod = class_getClassMethod(self, swizzledSelector)
		else { return }
		method_exchangeImplementations(originalMethod, swizzledMethod)
	}
}

extension Locale {
	///	This should be set to the language you used as Base localization
	fileprivate static var fallbackLanguageCode: String { return AppLocale.shared.original.languageCode ?? "en" }

	///	There is no sensible default for regionCode, as customers can be anywhere.
	///	Thus optional String
	fileprivate static var fallbackRegionCode: String? { return AppLocale.shared.original.regionCode }


	///	Saves chosen language and (optional) region code to UserDefaults so they can be restored on future app starts
	///
	/// - Parameters:
	///   - code: two-letter ISO 639-1 language code
	///   - regionCode: two-letter ISO 3166-1 code
	fileprivate static func enforceLanguage(code: String, regionCode: String? = nil) {
		//	save this choice so it's automatically loaded on next cold start of the app
		UserDefaults.languageCode = code
		UserDefaults.regionCode = regionCode

		//	load translated bundle for the chosen language
		Bundle.enforceLanguage(code)

		//	update all cached stuff in the app
		DateFormatter.resetupCashed()
		NumberFormatter.resetupCashed()
	}


	///	Call this from wherever in the app's UI you are allowing the customer to change the language / region
	///
	/// - Parameters:
	///   - code: two-letter ISO 639-1 language code
	///   - regionCode: two-letter ISO 3166-1 code
	static func updateLanguage(language: String, regionCode: String? = nil) {
        setDateFormat(to: language)
        UserDefaults.standard.setValue(language, forKey: UserDefaultKeys.selectedAppLanguage.rawValue)
        let isLanguageRTL = Locale.characterDirection(forLanguage: language) == .rightToLeft
        UIView.appearance().semanticContentAttribute = isLanguageRTL == true ? .forceRightToLeft : .forceLeftToRight
        UserDefaults.standard.set(isLanguageRTL, forKey: "AppleTe  zxtDirection")
        UserDefaults.standard.set(isLanguageRTL, forKey: "NSForceRightToLeftWritingDirection")
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.set(language, forKey: "i18n_language")
        UserDefaults.standard.set(language, forKey: "app_lang")
        UserDefaults.standard.synchronize()
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else { return }
        enforceLanguage(code: language, regionCode: regionCode)
        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle(path: path), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);

		//	post notification so the app views can update themselves
		NotificationCenter.default.post(name: NSLocale.currentLocaleDidChangeNotification, object: Locale.current)
	}


	///	Removes saved language/region from UserDefaults, 
	///	removes the custom translation bundle, resets Formatter cache,
	///	posts notification so views can update themselves
	static func clearInAppOverrides() {
		UserDefaults.languageCode = nil
		UserDefaults.regionCode = nil

		Bundle.clearInAppOverrides()

		//	update all cached stuff in the app
		DateFormatter.resetupCashed()
		NumberFormatter.resetupCashed()

		//	post notification so the app views can update themselves
		NotificationCenter.default.post(name: NSLocale.currentLocaleDidChangeNotification, object: Locale.current)
	}


	///	Call this as early as possible in application lifecycle, 
	///	say in `application(_:willFinishLaunchingWithOptions:)`
	static func setupInitialLanguage() {
		let _ = AppLocale.shared

		NSLocale.swizzle(selector: #selector(getter: NSLocale.current), with: #selector(getter: NSLocale.app))
		NSLocale.swizzle(selector: #selector(getter: NSLocale.preferredLanguages), with: #selector(getter: NSLocale.appPreferredLanguages))

		//	if there is language chosen in-app, then restore that choice
		if let languageCode = UserDefaults.languageCode {
			let regionCode = UserDefaults.regionCode
			enforceLanguage(code: languageCode, regionCode: regionCode)

			//	post notification so the app views can update themselves
			NotificationCenter.default.post(name: NSLocale.currentLocaleDidChangeNotification, object: Locale.current)
			return
		}

		//	If customer has never chosen any language overrides, 
		//	then it would fallback to original Locale.current
	}


	///	Returns `true` if given Locale uses right to left direction
	var isRightToLeft: Bool {
		guard let languageCode = languageCode else { return false }
		return Locale.characterDirection(forLanguage: languageCode) == .rightToLeft
	}
}
