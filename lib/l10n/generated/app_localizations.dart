import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @alertsAndNotifications.
  ///
  /// In en, this message translates to:
  /// **'Alerts & Notifications'**
  String get alertsAndNotifications;

  /// No description provided for @hardwareAndIot.
  ///
  /// In en, this message translates to:
  /// **'HARDWARE & IOT'**
  String get hardwareAndIot;

  /// No description provided for @wifiManagement.
  ///
  /// In en, this message translates to:
  /// **'WiFi Management'**
  String get wifiManagement;

  /// No description provided for @runConnectionWizard.
  ///
  /// In en, this message translates to:
  /// **'Run Connection Wizard'**
  String get runConnectionWizard;

  /// No description provided for @operatingThresholds.
  ///
  /// In en, this message translates to:
  /// **'Operating Thresholds'**
  String get operatingThresholds;

  /// No description provided for @thresholdsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fan, Heater, pH pump, Feeding pump limits'**
  String get thresholdsSubtitle;

  /// No description provided for @sensorCalibration.
  ///
  /// In en, this message translates to:
  /// **'Sensor Calibration'**
  String get sensorCalibration;

  /// No description provided for @calibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'pH, EC, and Temperature'**
  String get calibrationSubtitle;

  /// No description provided for @firmwareUpdate.
  ///
  /// In en, this message translates to:
  /// **'Firmware Update'**
  String get firmwareUpdate;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date: v2.4.1'**
  String get upToDate;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'APP PREFERENCES'**
  String get appPreferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @signOutConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmationTitle;

  /// No description provided for @signOutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmationMessage;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Rayyan v2.4.1 Build 102'**
  String get appVersion;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @historyAndTrends.
  ///
  /// In en, this message translates to:
  /// **'History & Trends'**
  String get historyAndTrends;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsights;

  /// No description provided for @growthPredictions.
  ///
  /// In en, this message translates to:
  /// **'Growth Predictions'**
  String get growthPredictions;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpAndGuides.
  ///
  /// In en, this message translates to:
  /// **'Help & Guides'**
  String get helpAndGuides;

  /// No description provided for @realTimeSensors.
  ///
  /// In en, this message translates to:
  /// **'Real-time Sensors'**
  String get realTimeSensors;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get offline;

  /// No description provided for @vitality.
  ///
  /// In en, this message translates to:
  /// **'VITALITY'**
  String get vitality;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK,'**
  String get welcomeBack;

  /// No description provided for @alertsAndNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts & Notifications'**
  String get alertsAndNotificationsTitle;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @allSystemsNominal.
  ///
  /// In en, this message translates to:
  /// **'All Systems Nominal'**
  String get allSystemsNominal;

  /// No description provided for @noActiveAlerts.
  ///
  /// In en, this message translates to:
  /// **'No active alerts or warnings at this time.'**
  String get noActiveAlerts;

  /// No description provided for @historicalAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Historical Analytics'**
  String get historicalAnalytics;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available for this period'**
  String get noDataAvailable;

  /// No description provided for @aiInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsightsTitle;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @actionRequired.
  ///
  /// In en, this message translates to:
  /// **'ACTION REQUIRED'**
  String get actionRequired;

  /// No description provided for @dailyTip.
  ///
  /// In en, this message translates to:
  /// **'DAILY TIP'**
  String get dailyTip;

  /// No description provided for @systemCritical.
  ///
  /// In en, this message translates to:
  /// **'System Critical'**
  String get systemCritical;

  /// No description provided for @systemWarning.
  ///
  /// In en, this message translates to:
  /// **'System Warning'**
  String get systemWarning;

  /// No description provided for @systemOptimal.
  ///
  /// In en, this message translates to:
  /// **'System Optimal'**
  String get systemOptimal;

  /// No description provided for @criticalDescription.
  ///
  /// In en, this message translates to:
  /// **'Low water levels detected. Nutrient balance is severely compromised.'**
  String get criticalDescription;

  /// No description provided for @warningDescription.
  ///
  /// In en, this message translates to:
  /// **'Some readings are out of optimal range. Check sensors.'**
  String get warningDescription;

  /// No description provided for @optimalDescription.
  ///
  /// In en, this message translates to:
  /// **'All systems are functioning within optimal parameters.'**
  String get optimalDescription;

  /// No description provided for @phLevel.
  ///
  /// In en, this message translates to:
  /// **'pH Level'**
  String get phLevel;

  /// No description provided for @ecLevel.
  ///
  /// In en, this message translates to:
  /// **'EC Level'**
  String get ecLevel;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @waterLevel.
  ///
  /// In en, this message translates to:
  /// **'Water Level'**
  String get waterLevel;

  /// No description provided for @waitingForInsights.
  ///
  /// In en, this message translates to:
  /// **'Waiting for insights...'**
  String get waitingForInsights;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'ANALYSIS'**
  String get analysis;

  /// No description provided for @errorLoadingChart.
  ///
  /// In en, this message translates to:
  /// **'Error loading chart'**
  String get errorLoadingChart;

  /// No description provided for @systemCriticalDescription.
  ///
  /// In en, this message translates to:
  /// **'Low water levels detected. Nutrient balance is severely compromised.'**
  String get systemCriticalDescription;

  /// No description provided for @systemWarningDescription.
  ///
  /// In en, this message translates to:
  /// **'Some readings are out of optimal range. Check sensors.'**
  String get systemWarningDescription;

  /// No description provided for @systemOptimalDescription.
  ///
  /// In en, this message translates to:
  /// **'All systems are functioning within optimal parameters.'**
  String get systemOptimalDescription;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @controls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get controls;

  /// No description provided for @vision.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get vision;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @verifyEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email first.'**
  String get verifyEmailFirst;

  /// No description provided for @accountConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Account Confirmed'**
  String get accountConfirmed;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @rayyanTitle.
  ///
  /// In en, this message translates to:
  /// **'Rayyan'**
  String get rayyanTitle;

  /// No description provided for @rayyanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Hydroponics Management'**
  String get rayyanSubtitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @verificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification Sent'**
  String get verificationSent;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinFuture.
  ///
  /// In en, this message translates to:
  /// **'Join the future of automated farming'**
  String get joinFuture;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Alex Rivera'**
  String get fullNameHint;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset Link Sent'**
  String get resetLinkSent;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @verificationSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent you a verification link to your email. Please check it.'**
  String get verificationSentMessage;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterAPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterAPassword;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordLengthError;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you instructions to reset your password.'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetLinkSentMessage.
  ///
  /// In en, this message translates to:
  /// **'A password reset link has been sent to your email address.'**
  String get resetLinkSentMessage;

  /// No description provided for @emailHintExample.
  ///
  /// In en, this message translates to:
  /// **'smith@gmail.com'**
  String get emailHintExample;

  /// No description provided for @statusOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get statusOk;

  /// No description provided for @statusWarning.
  ///
  /// In en, this message translates to:
  /// **'WARNING'**
  String get statusWarning;

  /// No description provided for @statusCritical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get statusCritical;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'--'**
  String get statusUnknown;

  /// No description provided for @vitalitySystemOffline.
  ///
  /// In en, this message translates to:
  /// **'System Offline\n This is the last data received. Please check your connection'**
  String get vitalitySystemOffline;

  /// No description provided for @vitalityWaitingForData.
  ///
  /// In en, this message translates to:
  /// **'Waiting for data...'**
  String get vitalityWaitingForData;

  /// No description provided for @vitalityCriticalLowWater.
  ///
  /// In en, this message translates to:
  /// **'Critical: Low Water'**
  String get vitalityCriticalLowWater;

  /// No description provided for @vitalityLowWater.
  ///
  /// In en, this message translates to:
  /// **'Low Water'**
  String get vitalityLowWater;

  /// No description provided for @vitalityTempUnstable.
  ///
  /// In en, this message translates to:
  /// **'Temp Unstable'**
  String get vitalityTempUnstable;

  /// No description provided for @vitalityPhUnstable.
  ///
  /// In en, this message translates to:
  /// **'pH Unstable'**
  String get vitalityPhUnstable;

  /// No description provided for @vitalityEcUnstable.
  ///
  /// In en, this message translates to:
  /// **'Ec Unstable'**
  String get vitalityEcUnstable;

  /// No description provided for @vitalitySystemNominal.
  ///
  /// In en, this message translates to:
  /// **'System Nominal'**
  String get vitalitySystemNominal;

  /// No description provided for @defaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUser;

  /// No description provided for @celsiusUnit.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get celsiusUnit;

  /// No description provided for @connectTo.
  ///
  /// In en, this message translates to:
  /// **'Connect to'**
  String get connectTo;

  /// No description provided for @chatWithRayyan.
  ///
  /// In en, this message translates to:
  /// **'Chat with Rayyan'**
  String get chatWithRayyan;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @passwordUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// No description provided for @thresholdsSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Thresholds saved successfully'**
  String get thresholdsSavedSuccessfully;

  /// No description provided for @noUserData.
  ///
  /// In en, this message translates to:
  /// **'No user data found'**
  String get noUserData;

  /// No description provided for @errorSigningOut.
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {error}'**
  String errorSigningOut(Object error);

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(Object error);

  /// No description provided for @alertDismissed.
  ///
  /// In en, this message translates to:
  /// **'{title} dismissed'**
  String alertDismissed(Object title);

  /// No description provided for @supportAndLearning.
  ///
  /// In en, this message translates to:
  /// **'Support & Learning'**
  String get supportAndLearning;

  /// No description provided for @videoGuides.
  ///
  /// In en, this message translates to:
  /// **'Video Guides'**
  String get videoGuides;

  /// No description provided for @visualWalkthroughs.
  ///
  /// In en, this message translates to:
  /// **'Visual walkthroughs for your system'**
  String get visualWalkthroughs;

  /// No description provided for @settingUpReservoir.
  ///
  /// In en, this message translates to:
  /// **'Setting up your Reservoir'**
  String get settingUpReservoir;

  /// No description provided for @nutrientMixingGuide.
  ///
  /// In en, this message translates to:
  /// **'Automated nutrient mixing guide'**
  String get nutrientMixingGuide;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @searchFaqsHint.
  ///
  /// In en, this message translates to:
  /// **'Search FAQs...'**
  String get searchFaqsHint;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResultsFound;

  /// No description provided for @faqQuestion1.
  ///
  /// In en, this message translates to:
  /// **'What is the ideal pH range?'**
  String get faqQuestion1;

  /// No description provided for @faqAnswer1.
  ///
  /// In en, this message translates to:
  /// **'For most hydroponic plants, keep the pH between 5.5 and 6.5. Regular testing is essential for nutrient uptake.'**
  String get faqAnswer1;

  /// No description provided for @faqQuestion2.
  ///
  /// In en, this message translates to:
  /// **'How do I maintain my pump?'**
  String get faqQuestion2;

  /// No description provided for @faqAnswer2.
  ///
  /// In en, this message translates to:
  /// **'Clean your pump monthly to prevent clogging. Ensure it is fully submerged at all times to avoid overheating.'**
  String get faqAnswer2;

  /// No description provided for @faqQuestion3.
  ///
  /// In en, this message translates to:
  /// **'What is the best lighting schedule?'**
  String get faqQuestion3;

  /// No description provided for @faqAnswer3.
  ///
  /// In en, this message translates to:
  /// **'Leafy greens typically need 14-16 hours of light daily. Fruiting plants may require more specific cycles.'**
  String get faqAnswer3;

  /// No description provided for @faqQuestion4.
  ///
  /// In en, this message translates to:
  /// **'How should I mix nutrients?'**
  String get faqQuestion4;

  /// No description provided for @faqAnswer4.
  ///
  /// In en, this message translates to:
  /// **'Always add nutrients to water, never mix them directly. Follow the order: Micro, Grow, then Bloom.'**
  String get faqAnswer4;

  /// No description provided for @faqQuestion5.
  ///
  /// In en, this message translates to:
  /// **'How do I enable app notifications?'**
  String get faqQuestion5;

  /// No description provided for @faqAnswer5.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Notifications to enable alerts for critical metrics like low water levels or pH imbalance.'**
  String get faqAnswer5;

  /// No description provided for @faqQuestion6.
  ///
  /// In en, this message translates to:
  /// **'What is the ideal water temperature?'**
  String get faqQuestion6;

  /// No description provided for @faqAnswer6.
  ///
  /// In en, this message translates to:
  /// **'Maintain water temperature between 65°F and 70°F (18°C - 21°C). Too warm can lead to root rot; too cold slows growth.'**
  String get faqAnswer6;

  /// No description provided for @faqQuestion7.
  ///
  /// In en, this message translates to:
  /// **'Why are my plant leaves turning yellow?'**
  String get faqQuestion7;

  /// No description provided for @faqAnswer7.
  ///
  /// In en, this message translates to:
  /// **'Yellow leaves often indicate nutrient deficiency (usually Nitrogen) or pH imbalance blocking nutrient uptake.'**
  String get faqAnswer7;

  /// No description provided for @faqQuestion8.
  ///
  /// In en, this message translates to:
  /// **'How far apart should I space my plants?'**
  String get faqQuestion8;

  /// No description provided for @faqAnswer8.
  ///
  /// In en, this message translates to:
  /// **'Space lettuce and herbs 6-8 inches apart. Larger fruiting plants like tomatoes need 12-18 inches of space.'**
  String get faqAnswer8;

  /// No description provided for @faqQuestion9.
  ///
  /// In en, this message translates to:
  /// **'How often should I clean the system?'**
  String get faqQuestion9;

  /// No description provided for @faqAnswer9.
  ///
  /// In en, this message translates to:
  /// **'Perform a full system flush and cleaning every 2-3 weeks to prevent algae buildup and salt accumulation.'**
  String get faqAnswer9;

  /// No description provided for @accountSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurityTitle;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsMismatch;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @updatePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePasswordButton;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @sensorCalibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Sensor Calibration'**
  String get sensorCalibrationTitle;

  /// No description provided for @logLabel.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get logLabel;

  /// No description provided for @calibrationInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'For accurate readings, calibrate sensors monthly using standard buffer solutions.'**
  String get calibrationInfoMessage;

  /// No description provided for @phSensor.
  ///
  /// In en, this message translates to:
  /// **'pH Sensor'**
  String get phSensor;

  /// No description provided for @ecSensor.
  ///
  /// In en, this message translates to:
  /// **'EC Sensor'**
  String get ecSensor;

  /// No description provided for @currentValue.
  ///
  /// In en, this message translates to:
  /// **'Current: {value}'**
  String currentValue(String value);

  /// No description provided for @lastCalibration.
  ///
  /// In en, this message translates to:
  /// **'Last: {time}'**
  String lastCalibration(String time);

  /// No description provided for @calibrateNow.
  ///
  /// In en, this message translates to:
  /// **'Calibrate Now'**
  String get calibrateNow;

  /// No description provided for @daysAgo2.
  ///
  /// In en, this message translates to:
  /// **'2 days ago'**
  String get daysAgo2;

  /// No description provided for @daysAgo5.
  ///
  /// In en, this message translates to:
  /// **'5 days ago'**
  String get daysAgo5;

  /// No description provided for @operatingThresholdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Operating Thresholds'**
  String get operatingThresholdsTitle;

  /// No description provided for @thresholdsInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'These limits control when fans, heaters, and pumps operate automatically.'**
  String get thresholdsInfoMessage;

  /// No description provided for @fanLimitHighLabel.
  ///
  /// In en, this message translates to:
  /// **'Fan Limit (temp_high)'**
  String get fanLimitHighLabel;

  /// No description provided for @fanLimitHighHint.
  ///
  /// In en, this message translates to:
  /// **'°C - Fan operating limit'**
  String get fanLimitHighHint;

  /// No description provided for @heaterLimitLowLabel.
  ///
  /// In en, this message translates to:
  /// **'Heater Limit (temp_low)'**
  String get heaterLimitLowLabel;

  /// No description provided for @heaterLimitLowHint.
  ///
  /// In en, this message translates to:
  /// **'°C - Heater operating limit'**
  String get heaterLimitLowHint;

  /// No description provided for @phHighLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'pH Pump Limit (ph_high)'**
  String get phHighLimitLabel;

  /// No description provided for @phHighLimitHint.
  ///
  /// In en, this message translates to:
  /// **'pH - pH pump operating limit'**
  String get phHighLimitHint;

  /// No description provided for @phLowLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'pH Pump Limit (ph_low)'**
  String get phLowLimitLabel;

  /// No description provided for @phLowLimitHint.
  ///
  /// In en, this message translates to:
  /// **'pH - pH lower bound'**
  String get phLowLimitHint;

  /// No description provided for @ecHighLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Feeding Pump Limit (ec_high)'**
  String get ecHighLimitLabel;

  /// No description provided for @ecHighLimitHint.
  ///
  /// In en, this message translates to:
  /// **'mS/cm - Feeding pump off limit'**
  String get ecHighLimitHint;

  /// No description provided for @ecLowLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Feeding Pump Limit (ec_low)'**
  String get ecLowLimitLabel;

  /// No description provided for @ecLowLimitHint.
  ///
  /// In en, this message translates to:
  /// **'mS/cm - Feeding pump operating limit'**
  String get ecLowLimitHint;

  /// No description provided for @saveThresholds.
  ///
  /// In en, this message translates to:
  /// **'Save Thresholds'**
  String get saveThresholds;

  /// No description provided for @phCalibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'pH Calibration'**
  String get phCalibrationTitle;

  /// No description provided for @currentReading.
  ///
  /// In en, this message translates to:
  /// **'Current Reading'**
  String get currentReading;

  /// No description provided for @signalStable.
  ///
  /// In en, this message translates to:
  /// **'Signal Stable'**
  String get signalStable;

  /// No description provided for @calibrationWizard.
  ///
  /// In en, this message translates to:
  /// **'Calibration Wizard'**
  String get calibrationWizard;

  /// No description provided for @prepareBuffer7.
  ///
  /// In en, this message translates to:
  /// **'Prepare Buffer 7.0'**
  String get prepareBuffer7;

  /// No description provided for @prepareBuffer7Sub.
  ///
  /// In en, this message translates to:
  /// **'Clean probe with distilled water and place in pH 7.0 solution.'**
  String get prepareBuffer7Sub;

  /// No description provided for @prepareBuffer4.
  ///
  /// In en, this message translates to:
  /// **'Prepare Buffer 4.0'**
  String get prepareBuffer4;

  /// No description provided for @prepareBuffer4Sub.
  ///
  /// In en, this message translates to:
  /// **'Rinse probe again and place in pH 4.0 solution.'**
  String get prepareBuffer4Sub;

  /// No description provided for @finalizeCalibration.
  ///
  /// In en, this message translates to:
  /// **'Finalize'**
  String get finalizeCalibration;

  /// No description provided for @finalizeCalibrationSub.
  ///
  /// In en, this message translates to:
  /// **'Save new calibration data to flash memory.'**
  String get finalizeCalibrationSub;

  /// No description provided for @calibratePoint7.
  ///
  /// In en, this message translates to:
  /// **'Calibrate Point 7.0'**
  String get calibratePoint7;

  /// No description provided for @calibratePoint4.
  ///
  /// In en, this message translates to:
  /// **'Calibrate Point 4.0'**
  String get calibratePoint4;

  /// No description provided for @saveCalibration.
  ///
  /// In en, this message translates to:
  /// **'Save Calibration'**
  String get saveCalibration;

  /// No description provided for @ecCalibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'EC Calibration'**
  String get ecCalibrationTitle;

  /// No description provided for @currentConductivity.
  ///
  /// In en, this message translates to:
  /// **'Current Conductivity'**
  String get currentConductivity;

  /// No description provided for @ecProbeWarning.
  ///
  /// In en, this message translates to:
  /// **'Ensure the probe is clean and free of organic buildup before calibrating.'**
  String get ecProbeWarning;

  /// No description provided for @calibrationStandard.
  ///
  /// In en, this message translates to:
  /// **'Calibration Standard'**
  String get calibrationStandard;

  /// No description provided for @calibrationStandardValue.
  ///
  /// In en, this message translates to:
  /// **'1.413 mS/cm (Standard)'**
  String get calibrationStandardValue;

  /// No description provided for @tempCompensation.
  ///
  /// In en, this message translates to:
  /// **'Temperature Compensation'**
  String get tempCompensation;

  /// No description provided for @tempCompensationValue.
  ///
  /// In en, this message translates to:
  /// **'2.0% / °C'**
  String get tempCompensationValue;

  /// No description provided for @fixedLabel.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixedLabel;

  /// No description provided for @startOnePointCalibration.
  ///
  /// In en, this message translates to:
  /// **'Start 1-Point Calibration'**
  String get startOnePointCalibration;

  /// No description provided for @tempCalibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Temp Calibration'**
  String get tempCalibrationTitle;

  /// No description provided for @sensorReading.
  ///
  /// In en, this message translates to:
  /// **'Sensor Reading'**
  String get sensorReading;

  /// No description provided for @rawValue.
  ///
  /// In en, this message translates to:
  /// **'Raw Value: {value}°C'**
  String rawValue(String value);

  /// No description provided for @manualOffsetAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Manual Offset Adjustment'**
  String get manualOffsetAdjustment;

  /// No description provided for @offsetInstructions.
  ///
  /// In en, this message translates to:
  /// **'Use a certified reference thermometer to determine the offset required.'**
  String get offsetInstructions;

  /// No description provided for @offsetLabel.
  ///
  /// In en, this message translates to:
  /// **'OFFSET °C'**
  String get offsetLabel;

  /// No description provided for @applyOffset.
  ///
  /// In en, this message translates to:
  /// **'Apply Offset'**
  String get applyOffset;

  /// No description provided for @firmwareUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Firmware Update'**
  String get firmwareUpdateTitle;

  /// No description provided for @systemUpToDate.
  ///
  /// In en, this message translates to:
  /// **'System is Up to Date'**
  String get systemUpToDate;

  /// No description provided for @installedVersion.
  ///
  /// In en, this message translates to:
  /// **'Installed Version: {version}'**
  String installedVersion(String version);

  /// No description provided for @changelogTitle.
  ///
  /// In en, this message translates to:
  /// **'Changelog {version}'**
  String changelogTitle(String version);

  /// No description provided for @releasedDate.
  ///
  /// In en, this message translates to:
  /// **'Released Oct 24, 2023'**
  String get releasedDate;

  /// No description provided for @changelogItem1.
  ///
  /// In en, this message translates to:
  /// **'Improved pH sensor stability algorithm'**
  String get changelogItem1;

  /// No description provided for @changelogItem2.
  ///
  /// In en, this message translates to:
  /// **'New \"Eco Mode\" for lighting schedule'**
  String get changelogItem2;

  /// No description provided for @changelogItem3.
  ///
  /// In en, this message translates to:
  /// **'Bug fixes for WiFi reconnection logic'**
  String get changelogItem3;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSub.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable all notifications'**
  String get pushNotificationsSub;

  /// No description provided for @alertsAndWarningsSection.
  ///
  /// In en, this message translates to:
  /// **'ALERTS & WARNINGS'**
  String get alertsAndWarningsSection;

  /// No description provided for @criticalSystemFailures.
  ///
  /// In en, this message translates to:
  /// **'Critical System Failures'**
  String get criticalSystemFailures;

  /// No description provided for @criticalSystemFailuresSub.
  ///
  /// In en, this message translates to:
  /// **'Pump failure, leak detection, power loss'**
  String get criticalSystemFailuresSub;

  /// No description provided for @waterLevelAlerts.
  ///
  /// In en, this message translates to:
  /// **'Water Level Alerts'**
  String get waterLevelAlerts;

  /// No description provided for @waterLevelAlertsSub.
  ///
  /// In en, this message translates to:
  /// **'Low water level, refilling required'**
  String get waterLevelAlertsSub;

  /// No description provided for @parameterWarnings.
  ///
  /// In en, this message translates to:
  /// **'Parameter Warnings'**
  String get parameterWarnings;

  /// No description provided for @parameterWarningsSub.
  ///
  /// In en, this message translates to:
  /// **'pH or EC deviation outside safe range'**
  String get parameterWarningsSub;

  /// No description provided for @wifiSetup.
  ///
  /// In en, this message translates to:
  /// **'WiFi Setup'**
  String get wifiSetup;

  /// No description provided for @helpLabel.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpLabel;

  /// No description provided for @discoverStep.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverStep;

  /// No description provided for @networkStep.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkStep;

  /// No description provided for @finishStep.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishStep;

  /// No description provided for @selectNetwork.
  ///
  /// In en, this message translates to:
  /// **'Select Network'**
  String get selectNetwork;

  /// No description provided for @scanningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scanning for nearby networks. Select your 2.4GHz home network.'**
  String get scanningSubtitle;

  /// No description provided for @scanningForEsp32.
  ///
  /// In en, this message translates to:
  /// **'Scanning for ESP32 module...'**
  String get scanningForEsp32;

  /// No description provided for @availableNetworks.
  ///
  /// In en, this message translates to:
  /// **'Available Networks'**
  String get availableNetworks;

  /// No description provided for @rescanForNetworks.
  ///
  /// In en, this message translates to:
  /// **'Rescan for Networks'**
  String get rescanForNetworks;

  /// No description provided for @askMeAboutHydroponic.
  ///
  /// In en, this message translates to:
  /// **'Ask me about your hydroponic system!'**
  String get askMeAboutHydroponic;

  /// No description provided for @typeYourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Type your question...'**
  String get typeYourQuestion;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorMessage(String error);

  /// No description provided for @smartControls.
  ///
  /// In en, this message translates to:
  /// **'Smart Controls'**
  String get smartControls;

  /// No description provided for @systemOperationMode.
  ///
  /// In en, this message translates to:
  /// **'System Operation Mode'**
  String get systemOperationMode;

  /// No description provided for @smartAuto.
  ///
  /// In en, this message translates to:
  /// **'Smart Auto'**
  String get smartAuto;

  /// No description provided for @manualOverride.
  ///
  /// In en, this message translates to:
  /// **'Manual Override'**
  String get manualOverride;

  /// No description provided for @hardwareModules.
  ///
  /// In en, this message translates to:
  /// **'Hardware Modules'**
  String get hardwareModules;

  /// No description provided for @waterPump.
  ///
  /// In en, this message translates to:
  /// **'Water Pump'**
  String get waterPump;

  /// No description provided for @ventilationFan.
  ///
  /// In en, this message translates to:
  /// **'Ventilation Fan'**
  String get ventilationFan;

  /// No description provided for @raiseEc.
  ///
  /// In en, this message translates to:
  /// **'Raise EC'**
  String get raiseEc;

  /// No description provided for @lowerEc.
  ///
  /// In en, this message translates to:
  /// **'Lower EC'**
  String get lowerEc;

  /// No description provided for @raisePh.
  ///
  /// In en, this message translates to:
  /// **'Raise pH'**
  String get raisePh;

  /// No description provided for @lowerPh.
  ///
  /// In en, this message translates to:
  /// **'Lower pH'**
  String get lowerPh;

  /// No description provided for @uvLight.
  ///
  /// In en, this message translates to:
  /// **'UV Light'**
  String get uvLight;

  /// No description provided for @heatGen.
  ///
  /// In en, this message translates to:
  /// **'Heat Gen'**
  String get heatGen;

  /// No description provided for @manualOverrideWarning.
  ///
  /// In en, this message translates to:
  /// **'Manual override is active. You control all modules at your own risk. Switch to Smart Auto for system-managed operation.'**
  String get manualOverrideWarning;

  /// No description provided for @smartAutoInfo.
  ///
  /// In en, this message translates to:
  /// **'Smart Auto mode: System controls all modules automatically. Switch to Manual Override to take control.'**
  String get smartAutoInfo;

  /// No description provided for @onStatus.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get onStatus;

  /// No description provided for @offStatus.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get offStatus;

  /// No description provided for @alertCriticalTitle.
  ///
  /// In en, this message translates to:
  /// **'🚨 Critical: {label} Issue'**
  String alertCriticalTitle(String label);

  /// No description provided for @alertWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Warning: {label} Issue'**
  String alertWarningTitle(String label);

  /// No description provided for @alertBody.
  ///
  /// In en, this message translates to:
  /// **'{label} is currently at {value}{unit}. Check system immediately.'**
  String alertBody(String label, String value, String unit);

  /// No description provided for @defaultDailyTip.
  ///
  /// In en, this message translates to:
  /// **'Consistency is key to a healthy harvest.'**
  String get defaultDailyTip;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No Email'**
  String get noEmail;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
