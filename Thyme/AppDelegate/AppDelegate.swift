import UIKit
import AVFoundation

let ThymeAlarmIDKey = "HYPAlarmID"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BITHockeyManagerDelegate, UIAlertViewDelegate {

  lazy var window: UIWindow? = {
    return UIWindow(frame: UIScreen.mainScreen().bounds)
    }()

  lazy var navigationController: UINavigationController = {
    let navigationController = UINavigationController(rootViewController: self.homeController)
    navigationController.navigationBarHidden = true

    return navigationController
    }()

  lazy var audioPlayer: AVAudioPlayer = {
    var error: NSError?

    let path = NSBundle.mainBundle().pathForResource("alarm", ofType: "caf")
    let file = NSURL(fileURLWithPath: path!)
    let audioPlayer = AVAudioPlayer(contentsOfURL: file, error: &error)

    if error != nil {
      println("error loading sound")
    }

    return audioPlayer
  }()

  lazy var homeController = {
    return HomeViewController()
    }()

  lazy var isUnitTesting: Bool = {
    let enviorment = NSProcessInfo.processInfo().environment
    
    if let injectBundlePath = enviorment["XCInjectBundle"] as? String
      where injectBundlePath.pathExtension == "xctest" {
        return true
    }
    
    return false
    }()

  // MARK: UIApplicationDelegate

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    #if DEBUG
      if isUnitTesting() { return true }
    #endif

    #if IS_PRE_RELEASE_VERSION
      BITHockeyManager.sharedHockeyManager().configureWithIdentifier("2cf664c4f20eed78d8ef3fe53f27fe3b", delegate: self)
      BITHockeyManager.sharedHockeyManager().startManager()
    #endif

    let pageControl = UIPageControl.appearance()
    pageControl.pageIndicatorTintColor = UIColor(fromHex: "D0E8E8")
    pageControl.currentPageIndicatorTintColor = UIColor(fromHex: "FF5C5C")
    pageControl.backgroundColor = UIColor(fromHex: "EDFFFF")

    UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)

    if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
      self.handleLocalNotification(notification, playingSound: false)
    }

    window!.rootViewController = navigationController
    window!.makeKeyAndVisible()

    return true
  }

  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    let state = UIApplication.sharedApplication().applicationState
    var playingSound = true

    if state == .Background || state == .Inactive {
      playingSound = false
    }

    self.handleLocalNotification(notification, playingSound: playingSound)
  }

  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    let types: UIUserNotificationType = .Alert | .Badge | .Sound
    if notificationSettings.types != types {
      self.homeController.cancelledNotifications()
    } else {
      self.homeController.registeredForNotifications()
    }
  }

  // MARK: UIAlertViewDelegate

  func alert(alertView: UIAlertView, clickedButtonAtIndex: NSInteger) {
    self.audioPlayer.stop()
  }

  // MARK: Private methods

  func handleLocalNotification(notification: UILocalNotification, playingSound: Bool) {
    if let userInfo = notification.userInfo,
    alarmID = userInfo[ThymeAlarmIDKey] as? String {
      println(alarmID)
      self.cleanUpLocalNotificationWithAlarmID(alarmID)

      if playingSound {
        audioPlayer.prepareToPlay()
        audioPlayer.play()
      }
      
      UIAlertView(title: notification.alertBody,
        message: nil,
        delegate: self,
        cancelButtonTitle: "OK").show()
    }
  }

  func cleanUpLocalNotificationWithAlarmID(alarmID: String) {
    UIApplication.sharedApplication().applicationIconBadgeNumber = 1
    UIApplication.sharedApplication().applicationIconBadgeNumber = 0

    if let notification = HYPLocalNotificationManager.existingNotificationWithAlarmID(alarmID) {
      UIApplication.sharedApplication().cancelLocalNotification(notification)
    }
  }

}
