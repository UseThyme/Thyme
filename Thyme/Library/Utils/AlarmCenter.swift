import Foundation

public struct AlarmCenter {

  enum Action: String {
    case AddThreeMinutes = "AddThreeMinutes"
    case AddFiveMinutes = "AddFiveMinutes"
  }

  static let categoryIdentifier = "ThymeCategory"

  struct Notifications {
    static let AlarmsDidUpdate = "WatchHandler.AlarmsDidUpdate"
  }

  // MARK: - Local notification management

  static func registerNotificationSettings() {
    var categories = Set<UIUserNotificationCategory>()

    let threeMinutesAction = UIMutableUserNotificationAction()
    threeMinutesAction.title = NSLocalizedString("Add 3 mins", comment: "")
    threeMinutesAction.identifier = Action.AddThreeMinutes.rawValue
    threeMinutesAction.activationMode = .Background
    threeMinutesAction.authenticationRequired = false

    let fiveMinutesAction = UIMutableUserNotificationAction()
    fiveMinutesAction.title = NSLocalizedString("Add 5 mins", comment: "")
    fiveMinutesAction.identifier = Action.AddFiveMinutes.rawValue
    fiveMinutesAction.activationMode = .Background
    fiveMinutesAction.authenticationRequired = false

    let category = UIMutableUserNotificationCategory()
    category.setActions([threeMinutesAction, fiveMinutesAction], forContext: .Default)
    category.identifier = AlarmCenter.categoryIdentifier

    categories.insert(category)

    let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
    let settings = UIUserNotificationSettings(forTypes: types, categories: categories)

    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
  }

  static func scheduleNotification(alarmID: String, seconds: NSTimeInterval, message: String?) -> UILocalNotification {
    let fireDate = NSDate().dateByAddingTimeInterval(seconds)

    var userInfo = [NSObject : AnyObject]()
    userInfo[ThymeAlarmIDKey] = alarmID
    userInfo[ThymeAlarmFireDataKey] = NSDate()
    userInfo[ThymeAlarmFireInterval] = seconds

    let notification = UILocalNotification()
    notification.alertBody = message
    notification.fireDate = fireDate
    notification.category = categoryIdentifier
    notification.soundName = "alarm.caf"
    notification.timeZone = NSTimeZone.defaultTimeZone()
    notification.userInfo = userInfo
    
    UIApplication.sharedApplication().scheduleLocalNotification(notification)

    return notification
  }

  static func extendNotification(alarmID: String, seconds: NSTimeInterval) -> UILocalNotification {
    var secondsAmount: NSTimeInterval = 0
    var alertBody = ""

    if let notification = AlarmCenter.getNotification(alarmID),
      userInfo = notification.userInfo,
      firedDate = userInfo[ThymeAlarmFireDataKey] as? NSDate,
      numberOfSeconds = userInfo[ThymeAlarmFireInterval] as? NSNumber {
        let secondsPassed: NSTimeInterval = NSDate().timeIntervalSinceDate(firedDate)
        let secondsLeft = NSTimeInterval(numberOfSeconds.integerValue) - secondsPassed
        secondsAmount = secondsLeft

        if let text = notification.alertBody {
          alertBody = text
        }

        UIApplication.sharedApplication().cancelLocalNotification(notification)
    }

    secondsAmount += seconds

    let notification = AlarmCenter.scheduleNotification(alarmID,
      seconds: secondsAmount,
      message: alertBody)

    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.AlarmsDidUpdate,
      object: notification)

    return notification
  }

  static func getNotification(alarmID: String) -> UILocalNotification? {
    for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
      if let notificationAlarmID = notification.userInfo?[ThymeAlarmIDKey] as? String
        where notificationAlarmID == alarmID {
          return notification
      }
    }
    return nil
  }

  static func cleanUpNotification(alarmID: String) {
    UIApplication.sharedApplication().applicationIconBadgeNumber = 1
    UIApplication.sharedApplication().applicationIconBadgeNumber = 0

    if let notification = getNotification(alarmID) {
      UIApplication.sharedApplication().cancelLocalNotification(notification)
    }
  }

  static func cancelAllNotifications() {
    for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
      if let _ = notification.userInfo?[ThymeAlarmIDKey] as? String {
        UIApplication.sharedApplication().cancelLocalNotification(notification)
      }
    }
  }

  // MARK: - Handling

  static func handleNotification(notification: UILocalNotification, actionID: String?) {
    if let actionID = actionID,
      action = Action(rawValue: actionID),
      alarmID = notification.userInfo?[ThymeAlarmIDKey] as? String {
        switch action {
        case .AddThreeMinutes:
          extendNotification(alarmID, seconds: NSTimeInterval(60 * 3))
        case .AddFiveMinutes:
          extendNotification(alarmID, seconds: NSTimeInterval(60 * 5))
        }
    }
  }
}
