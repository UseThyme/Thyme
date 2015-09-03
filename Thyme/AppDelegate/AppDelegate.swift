import UIKit
import AVFoundation
import WatchConnectivity

let ThymeAlarmIDKey = "HYPAlarmID"
let ThymeAlarmFireDataKey = "HYPAlarmFireDate"
let ThymeAlarmFireInterval = "HYPAlarmFireInterval"

@available(iOS 9.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BITHockeyManagerDelegate, UIAlertViewDelegate {

  lazy var window: UIWindow? = {
    return UIWindow(frame: UIScreen.mainScreen().bounds)
    }()

  lazy var navigationController: UINavigationController = { [unowned self] in
    let navigationController = UINavigationController(rootViewController: self.homeController)
    navigationController.navigationBarHidden = true

    return navigationController
    }()

  lazy var audioPlayer: AVAudioPlayer? = {
    var error: NSError?

    let path = NSBundle.mainBundle().pathForResource("alarm", ofType: "caf")
    let file = NSURL(fileURLWithPath: path!)
    var audioPlayer: AVAudioPlayer? = nil
    do { try audioPlayer = AVAudioPlayer(contentsOfURL: file) } catch { print("error loading sound") }

    return audioPlayer
  }()

  lazy var homeController: HomeViewController = {
    var theme: Themable = Theme.Main()

    if UIAccessibilityDarkerSystemColorsEnabled() {
      theme = Theme.DarkColors()

      if UIAccessibilityIsReduceTransparencyEnabled() {
        theme = Theme.HighContrast()
      }
    }
    let controller = HomeViewController(theme: theme)
    return controller
    }()

  lazy var isUnitTesting: Bool = {
    let enviorment = NSProcessInfo.processInfo().environment

    if let injectBundlePath = enviorment["XCInjectBundle"]
      where injectBundlePath.hasSuffix("xctest") {
        return true
    }

    return false
    }()

  var session: WCSession!

  // MARK: - UIApplicationDelegate

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    #if DEBUG
      if isUnitTesting() { return true }
    #endif

    #if IS_PRE_RELEASE_VERSION
      BITHockeyManager.sharedHockeyManager().configureWithIdentifier("2cf664c4f20eed78d8ef3fe53f27fe3b", delegate: self)
      BITHockeyManager.sharedHockeyManager().startManager()
    #endif

    let audioSession = AVAudioSession.sharedInstance()
    do { try audioSession.setCategory(AVAudioSessionCategoryPlayback) } catch {}
    do { try audioSession.setActive(true) } catch {}
    application.beginReceivingRemoteControlEvents()

    let pageControl = UIPageControl.appearance()
    pageControl.pageIndicatorTintColor = UIColor(hex: "D0E8E8")
    pageControl.currentPageIndicatorTintColor = UIColor(hex: "FF5C5C")
    pageControl.backgroundColor = UIColor(hex: "EDFFFF")

    if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
      handleLocalNotification(notification, playingSound: false)
    }

    if WCSession.isSupported() {
      session = WCSession.defaultSession()
      session.delegate = self
      session.activateSession()
    }

    window!.rootViewController = navigationController
    window!.makeKeyAndVisible()

    return true
  }

  func applicationDidBecomeActive(application: UIApplication) {
    var theme: Themable = Theme.Main()

    if UIAccessibilityDarkerSystemColorsEnabled() {
      theme = Theme.DarkColors()

      if UIAccessibilityIsReduceTransparencyEnabled() {
        theme = Theme.HighContrast()
      }
    }

    homeController.theme = theme
    homeController.setNeedsStatusBarAppearanceUpdate()
  }

  func applicationDidEnterBackground(application: UIApplication) {
    application.beginBackgroundTaskWithExpirationHandler {}
    application.beginReceivingRemoteControlEvents()
  }

  override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
    if motion == .MotionShake {
      NSNotificationCenter.defaultCenter().postNotificationName("appWasShaked", object: nil)
    }
  }
}

// MARK: - Local Notifications

@available(iOS 9.0, *)
extension AppDelegate {

  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
    if notificationSettings.types != types {
      homeController.cancelledNotifications()
    } else {
      homeController.registeredForNotifications()
    }
  }

  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    if UIApplication.sharedApplication().applicationState == .Active {
      handleLocalNotification(notification, playingSound: true)
    }
  }

  func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
    AlarmCenter.handleNotification(notification, actionID: identifier)
    if let audioPlayer = self.audioPlayer where audioPlayer.playing {
      self.audioPlayer!.stop()
    }

    completionHandler()
  }

  // MARK: Private methods

  func handleLocalNotification(notification: UILocalNotification, playingSound: Bool) {
    if let userInfo = notification.userInfo, _ = userInfo[ThymeAlarmIDKey] as? String {
      if playingSound {
        audioPlayer!.prepareToPlay()
        audioPlayer!.play()
      }

      let alert = UIAlertController(title: "Thyme", message: notification.alertBody, preferredStyle: .Alert)
      let actionAndDismiss = { (action: String?) -> ((UIAlertAction!) -> Void) in
        return { _ in
          AlarmCenter.handleNotification(notification, actionID: action)
          if let audioPlayer = self.audioPlayer where audioPlayer.playing {
            self.audioPlayer!.stop()
          }
        }
      }

      alert.addAction(UIAlertAction(title: "OK",
        style: .Cancel, handler: actionAndDismiss(nil)))
      alert.addAction(UIAlertAction(title: NSLocalizedString("Add 3 mins", comment: ""),
        style: .Default, handler: actionAndDismiss(AlarmCenter.Action.AddThreeMinutes.rawValue)))
      alert.addAction(UIAlertAction(title: NSLocalizedString("Add 5 mins", comment: ""),
        style: .Default, handler: actionAndDismiss(AlarmCenter.Action.AddFiveMinutes.rawValue)))

      navigationController.visibleViewController?.presentViewController(alert, animated: true, completion: nil)
    }
  }
}

// MARK: - WatchKit

@available(iOS 9.0, *)
extension AppDelegate: WCSessionDelegate {

  func session(session: WCSession, didReceiveMessage message: [String : AnyObject],
    replyHandler: ([String : AnyObject]) -> Void) {
      if let request = message["request"] as? String {
        replyHandler(WatchCommunicator.response(request, message))
      }
  }
}
