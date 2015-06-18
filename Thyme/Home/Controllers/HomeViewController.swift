import UIKit

class HomeViewController: HYPViewController {

  let plateCellIdentifier = "HYPPlateCellIdentifier"

  var maxMinutesLeft: NSNumber? {
    didSet(newValue) {
      if newValue != nil {
        self.titleLabel.text = NSLocalizedString("YOUR DISH WILL BE DONE",
          comment: "YOUR DISH WILL BE DONE");
        if (newValue == 0.0) {
          self.subtitleLabel.text = NSLocalizedString("IN LESS THAN A MINUTE",
            comment: "IN LESS THAN A MINUTE")
        } else {
          self.subtitleLabel.text = HYPAlarm.subtitleForHomescreenUsingMinutes(newValue)
        }
      } else {
        self.titleLabel.text = HYPAlarm.titleForHomescreen()
        self.subtitleLabel.text = HYPAlarm.subtitleForHomescreen()
      }
    }
  }

  lazy var topMargin: CGFloat = {
    let margin: CGFloat

    if UIScreen.andy_isPad() {
      margin  = 70
    } else {
      if self.deviceHeight == 480 {
        margin = 10
      } else if self.deviceHeight == 568 {
        margin = 50
      } else if self.deviceHeight == 667 {
        margin = 68
      } else {
        margin = 75
      }
    }

    return margin
  }()
  
  lazy var plateFactor: CGFloat = {
    let factor: CGFloat = UIScreen.andy_isPad() ? 0.36 : 0.30
    return factor
    }()

  lazy var ovenFactor: CGFloat = {
    let factor: CGFloat = UIScreen.andy_isPad() ? 0.29 : 0.25
    return factor
    }()

  lazy var deviceHeight: CGFloat = {
    return UIScreen.mainScreen().bounds.height
    }()

  lazy var deviceWidth: CGFloat = {
    return CGRectGetWidth(UIScreen.mainScreen().bounds)
    }()

  lazy var alarms: [[HYPAlarm]] = {
    var alarms = [[HYPAlarm]]()

    for i in 0...2 {
      alarms.append([HYPAlarm(), HYPAlarm()])
    }

    return alarms
    }()

  lazy var ovenAlarms: [[HYPAlarm]] = {
    var alarms = [[HYPAlarm]]()

    for i in 0...2 {
      let alarm = HYPAlarm()
      alarm.oven = true
      alarms.append([alarm])
    }

    return alarms
    }()

  lazy var titleLabel: UILabel = {
    let sideMargin: CGFloat = 20
    let width = self.deviceWidth - 2 * sideMargin
    let height: CGFloat = 25
    var topMargin: CGFloat = 0
    var font: UIFont

    if UIScreen.andy_isPad() {
      topMargin  = 115
      font = HYPUtils.avenirLightWithSize(20)
    } else {
      if self.deviceHeight == 480 || self.deviceHeight == 568 {
        topMargin = 60
        font = HYPUtils.avenirLightWithSize(15)
      } else if self.deviceHeight == 667 {
        topMargin = 74
        font = HYPUtils.avenirLightWithSize(18)
      } else {
        topMargin = 82
        font = HYPUtils.avenirLightWithSize(19)
      }
    }

    let label = UILabel(frame: CGRectMake(sideMargin, topMargin, width, height))
    label.font = font
    label.text = HYPAlarm.titleForHomescreen()
    label.textAlignment = .Center
    label.textColor = UIColor.whiteColor()
    label.backgroundColor = UIColor.clearColor()
    label.adjustsFontSizeToFitWidth = true

    return label
    }()

  lazy var subtitleLabel: UILabel = {
    let sideMargin: CGFloat = 20
    let width = self.deviceWidth - 2 * sideMargin
    let height = CGRectGetHeight(self.titleLabel.frame)
    var topMargin = CGRectGetMaxY(self.titleLabel.frame)
    var font: UIFont

    if UIScreen.andy_isPad() {
      topMargin += 10
      font = HYPUtils.avenirBlackWithSize(25)
    } else {
      if self.deviceHeight == 480 || self.deviceHeight == 568 {
        font = HYPUtils.avenirBlackWithSize(19)
      } else if self.deviceHeight == 667 {
        topMargin += 4
        font = HYPUtils.avenirBlackWithSize(22)
      } else {
        topMargin += 7
        font = HYPUtils.avenirBlackWithSize(24)
      }
    }

    let label = UILabel(frame: CGRectMake(sideMargin, topMargin, width, height))
    label.font = font
    label.text = HYPAlarm.subtitleForHomescreen()
    label.textAlignment = .Center
    label.textColor = UIColor.whiteColor()
    label.backgroundColor = UIColor.clearColor()
    label.adjustsFontSizeToFitWidth = true

    return label
    }()

  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    var cellWidth: CGFloat = 0
    var sideMargin: CGFloat = 0

    if UIScreen.andy_isPad() {
      cellWidth = 175
      sideMargin = 200
    } else {
      if self.deviceHeight == 480 || self.deviceHeight == 568 {
        cellWidth = 100
        sideMargin = 50
      } else if self.deviceHeight == 667 {
        cellWidth = 113
        sideMargin = 65
      } else {
        cellWidth = 122
        sideMargin = 75
      }
    }

    layout.itemSize = CGSizeMake(cellWidth + 10, cellWidth)
    layout.scrollDirection = .Horizontal

    let width: CGFloat = self.deviceWidth - 2 * sideMargin
    let collectionViewWidth = CGRectMake(sideMargin, self.topMargin, width, width)
    
    let collectionView = UICollectionView(frame: collectionViewWidth,
      collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = UIColor.clearColor()

    self.applyTransformToLayer(collectionView.layer, factor: self.plateFactor)

    return collectionView
    }()

  lazy var ovenCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    var topMargin: CGFloat = self.topMargin
    var cellWidth: CGFloat = 0
    var sideMargin: CGFloat = 0

    if UIScreen.andy_isPad() {
      cellWidth = 175
      sideMargin = 200
      topMargin += 475
    } else {
      if self.deviceHeight == 480 || self.deviceHeight == 568 {
        cellWidth = 120
        sideMargin = 100
        topMargin += 260
      } else if self.deviceHeight == 667 {
        cellWidth = 113
        sideMargin = 120
        topMargin += 300
      } else {
        cellWidth = 152
        sideMargin = 130
        topMargin += 328
      }
    }

    layout.itemSize = CGSizeMake(cellWidth + 10, cellWidth)
    layout.scrollDirection = .Horizontal

    let width: CGFloat = self.deviceWidth - 2 * sideMargin
    let collectionViewWidth = CGRectMake(sideMargin, topMargin, self.deviceWidth, self.deviceHeight)
    
    let collectionView = UICollectionView(frame: collectionViewWidth,
      collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = UIColor.clearColor()

    self.applyTransformToLayer(collectionView.layer, factor: self.ovenFactor)

    return collectionView
    }()

  lazy var ovenBackgroundImageView: UIImageView = {
    let imageView: UIImageView
    let imageName = UIScreen.andy_isPad()
      ? "ovenBackground~iPad"
      : "ovenBackground"
    let image = UIImage(named: imageName)

    var topMargin: CGFloat = image!.size.height
    var x: CGFloat = self.deviceWidth / 2 - image!.size.width / 2;
    var width: CGFloat = image!.size.width
    var height: CGFloat = image!.size.height

    if UIScreen.andy_isPad() {
      topMargin += 175
    } else {
      if self.deviceHeight == 480 {
        topMargin += 40
      }  else if self.deviceHeight == 568 {
        topMargin += 90
      } else if self.deviceHeight == 667 {
        topMargin += 128
        x = 50
      } else if self.deviceHeight == 763 {
        height = 173
        topMargin += 128
        width = 304
        x = 54
      }
    }

    let y = self.deviceHeight - topMargin
    imageView = UIImageView(frame: CGRectMake(x, y, width, height))
    imageView.image = image

    return imageView
    }()

  lazy var ovenShineImageView: UIImageView = {
    let imageView: UIImageView
    let imageName = UIScreen.andy_isPad()
      ? "ovenShine~iPad"
      : "ovenShine"
    let image = UIImage(named: imageName)

    imageView = UIImageView(frame: self.ovenBackgroundImageView.frame)
    imageView.image = image

    return imageView
    }()

  lazy var settingsButton: UIButton = {
    let button = UIButton.buttonWithType(.InfoLight) as! UIButton
    button.addTarget(self, action: "settingsButtonAction", forControlEvents: .TouchUpInside)

    let y: CGFloat = self.deviceHeight - 44 - 15
    let x: CGFloat = 5

    button.frame = CGRectMake(x,y,44,44)
    button.tintColor = UIColor.whiteColor()

    return button
  }()

  lazy var welcomeController: InstructionController = {
    let controller = InstructionController(
      image: UIImage(named: "welcomeIcon")!,
      title: NSLocalizedString("WelcomeTitle", comment: ""),
      message: NSLocalizedString("WelcomeMessage", comment: ""),
      hasAction: true,
      isWelcome: true,
      index: -1)
    controller.delegate = self

    return controller
  }()
    
  override func viewDidLoad() {
    super.viewDidLoad()

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWasShaked:", name: "appWasShaked", object: nil)

    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(ovenBackgroundImageView)
    view.addSubview(ovenShineImageView)

    collectionView.registerClass(PlateCell.classForCoder(), forCellWithReuseIdentifier: plateCellIdentifier)
    ovenCollectionView.registerClass(PlateCell.classForCoder(), forCellWithReuseIdentifier: plateCellIdentifier)
    
    view.addSubview(collectionView)
    view.addSubview(ovenCollectionView)
    view.addSubview(settingsButton)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "dismissedTimerController:",
      name: UIApplicationDidBecomeActiveNotification,
      object: nil)
      
    self.setNeedsStatusBarAppearanceUpdate()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    let registredSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
    let types: UIUserNotificationType = .Alert | .Badge | .Sound

    if registredSettings.types != types {
      let navigationController = UINavigationController(rootViewController: welcomeController)
      navigationController.navigationBarHidden = true
      presentViewController(navigationController,
        animated: true,
        completion: nil)
    }
  }

  override func prefersStatusBarHidden() -> Bool {
    return false
  }

  func settingsButtonAction() {
    //TODO: Implement this feature
  }
  
  func registeredForNotifications() {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func cancelledNotifications() {
    welcomeController.cancelledNotifications()
  }

  func applyTransformToLayer(layer: CALayer, factor: CGFloat) {
    let π = CGFloat(M_PI)
    var rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -800.0;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, π * factor, 1.0, 0.0, 0.0);
    layer.anchorPoint = CGPointMake(0.5, 0);
    layer.transform = rotationAndPerspectiveTransform;
  }

  func alarmAtIndexPath(indexPath: NSIndexPath, collectionView: UICollectionView) -> HYPAlarm {
    let row: [HYPAlarm]
    if collectionView.isEqual(self.collectionView) {
      row = self.alarms[indexPath.section]
    } else {
      row = self.ovenAlarms[indexPath.section]
    }

    return row[indexPath.row]
  }

  func configureCell(cell: PlateCell, indexPath: NSIndexPath, collectionView: UICollectionView) {
    let alarm = alarmAtIndexPath(indexPath, collectionView: collectionView)
    alarm.indexPath = indexPath

    cell.timerControl.active = alarm.active
    cell.timerControl.addTarget(self, action: "timerControlChangedValue:", forControlEvents: .ValueChanged)
    
    refreshTimerInCell(cell, alarm: alarm)
  }

  func refreshTimerInCell(cell: PlateCell, alarm: HYPAlarm) {
    if let existingNotification = HYPLocalNotificationManager.existingNotificationWithAlarmID(alarm.alarmID),
      userinfo = existingNotification.userInfo,
      firedDate = userinfo[ThymeAlarmFireDataKey] as? NSDate,
      numberOfSeconds = userinfo[ThymeAlarmFireInterval] as? NSNumber
    {
      let secondsPassed: NSTimeInterval = NSDate().timeIntervalSinceDate(firedDate)
      let secondsLeft = NSTimeInterval(numberOfSeconds.integerValue) - secondsPassed
      let currentSecond = secondsLeft % 60
      var minutesLeft = floor(secondsLeft/60)
      let hoursLeft = floor(minutesLeft/60)
      

      if let maxMinutes = self.maxMinutesLeft
        where minutesLeft > maxMinutes.doubleValue {
          maxMinutesLeft = minutesLeft
      }

      if hoursLeft > 0 {
        minutesLeft = minutesLeft - (hoursLeft * 60)
      }

      if minutesLeft < 0 {
        UIApplication.sharedApplication().cancelLocalNotification(existingNotification)
      }

      alarm.active = true
      cell.timerControl.active = true
      cell.timerControl.alarmID = alarm.alarmID
      cell.timerControl.seconds = Int(currentSecond)
      cell.timerControl.hours = Int(hoursLeft)
      cell.timerControl.minutes = Int(minutesLeft)
      cell.timerControl.startTimer()

      let defaults = NSUserDefaults.standardUserDefaults()
      defaults.setBool(true, forKey: "presentedClue")
      defaults.synchronize()

    } else {
      alarm.active = false
      cell.timerControl.active = false
      cell.timerControl.restartTimer()
      cell.timerControl.stopTimer()
    }
  }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return collectionView.isEqual(self.collectionView)
      ? self.alarms.count
      : self.ovenAlarms.count
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return collectionView.isEqual(self.collectionView)
    ? self.alarms[0].count
    : self.ovenAlarms[0].count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(plateCellIdentifier, forIndexPath: indexPath) as! PlateCell
    
    configureCell(cell, indexPath: indexPath, collectionView: collectionView)

    return cell
  }
}

extension HomeViewController: UICollectionViewDelegate {

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let alarm = alarmAtIndexPath(indexPath, collectionView: collectionView)
    let timerController = HYPTimerViewController()
    timerController.delegate = self
    timerController.alarm = alarm
    
    presentViewController(timerController, animated: true, completion: nil)
  }
}

// MARK: - InstructionDelegate

extension HomeViewController: InstructionDelegate {

  func instructionControllerDidTapAcceptButton(controller: InstructionController) {
    let types: UIUserNotificationType = .Alert | .Badge | .Sound
    let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
  }
}

// MARK: - HYPTimerControllerDelegate

extension HomeViewController: HYPTimerControllerDelegate {

  func dismissedTimerController(timerController: HYPTimerViewController!) {
    maxMinutesLeft = nil
    collectionView.reloadData()
    ovenCollectionView.reloadData()
  }

  func timerControlChangedValue(timerControl: HYPTimerControl) {
    if let maxMinutes = self.maxMinutesLeft
      where maxMinutes.intValue - 1 == timerControl.minutes {
        self.maxMinutesLeft = timerControl.minutes
    } else if let maxMinutes = self.maxMinutesLeft
      where maxMinutes.floatValue == Float(0) {
        self.maxMinutesLeft = nil
    }
  }
}
