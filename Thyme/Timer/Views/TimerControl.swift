import Foundation

public class TimerControl: UIControl {

  let CircleSizeFactor: CGFloat = 0.8

  var alarm: Alarm?
  var alarmID: String?
  var title: String = Alarm.messageForSetAlarm()
  var circleRect: CGRect = CGRectZero

  var seconds: Int = 0
  var touchesAreActive: Bool = false
  var completedMode: Bool
  var timer: NSTimer?
  var lastPoint: CGPoint = CGPointZero

  lazy var deviceHeight: CGFloat = {
    return UIScreen.mainScreen().bounds.height
    }()

  var angle: Int = 0 {
    didSet(value) {
      let minute = value/6
      if self.completedMode == false && self.isHoursMode == true {
        if minute < 10 {
          self.minutesValueLabel.text = "\(self.hours):0\(minute/6)"
        } else {
          self.minutesValueLabel.text = "\(self.hours)\(minute/6)"
        }
      } else {
        self.minutesValueLabel.text = "\(minute)"
      }
    }
  }

  var hours: Int = 0 {
    didSet(value) {
      if value == 0 {
        self.hoursLabel.hidden = true
      } else {
        self.hoursLabel.hidden = false
        self.hoursLabel.text = value == 1
          ? NSLocalizedString("\(value) HOUR", comment: "\(value) HOUR")
          : NSLocalizedString("\(value) HOURS", comment: "\(value) HOURS")
      }
    }
  }

  var minutes: Int = 0 {
    willSet(value) {
      if minutes != value && self.touchesAreActive == true {
        self.playInputClick()
      }

      self.angle = value * 6
      self.setNeedsDisplay()
    }
  }

  var active: Bool = false {
    didSet(value) {
      self.minutesValueLabel.hidden = !value
      self.angle = 0
      self.setNeedsDisplay()
    }
  }

  lazy var isHoursMode: Bool = {
    return self.hours > 0
    }()

  lazy var minuteValueSize: CGFloat = {
    if UIScreen.andy_isPad() {
      return 200
    } else {
      return 95
    }
    }()

  lazy var minuteTitleSize: CGFloat = {
    if UIScreen.andy_isPad() {
      return 35
    } else {
      return 14
    }
    }()

  lazy var hoursLabel: UILabel = {
    let bounds = UIScreen.mainScreen().bounds
    let defaultSize = self.completedMode == true
    ? self.minuteTitleSize
    : self.minuteTitleSize * 1.5

    let fontSize = floor(defaultSize * CGRectGetWidth(self.frame)) / CGRectGetWidth(bounds)
    let font = HYPUtils.avenirLightWithSize(fontSize)
    let sampleString = "2 HOURS"
    let attributes = [NSFontAttributeName : font]
    let textSize = (sampleString as NSString).sizeWithAttributes(attributes)
    let yOffset: CGFloat = self.minutesValueLabel.frame.origin.y - 8
    let x: CGFloat = 0
    let y: CGFloat = self.frame.size.height - textSize.height / 2 - yOffset
    let rect = CGRectMake(x, y, CGRectGetWidth(self.frame), textSize.height)
    let label = UILabel(frame: rect)

    label.backgroundColor = UIColor.clearColor()
    label.font = font
    label.hidden = true
    label.text = sampleString
    label.textAlignment = .Center

    let defaults = NSUserDefaults.standardUserDefaults()

    label.textColor = defaults.stringForKey("TextColor") != nil
    ? UIColor(fromHex: defaults.stringForKey("TextColor"))
    : UIColor(fromHex: "30cec6")

    return label
    }()

  lazy var minutesValueLabel: UILabel = {
    let bounds = UIScreen.mainScreen().bounds
    let defaultSize = self.completedMode == true
      ? self.minuteValueSize
      : self.minuteValueSize * 0.9

    let fontSize = floor(defaultSize * CGRectGetWidth(self.frame)) / CGRectGetWidth(bounds)
    let font = HYPUtils.helveticaNeueUltraLightWithSize(fontSize)
    let sampleString = "10:00"
    let attributes = [NSFontAttributeName : font]
    let textSize = (sampleString as NSString).sizeWithAttributes(attributes)
    let yOffset: CGFloat = 20 * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds)
    let x: CGFloat = 0
    let y: CGFloat = (self.frame.size.height - textSize.height) / 2 - yOffset
    let rect = CGRectMake(x, y, CGRectGetWidth(self.frame), textSize.height)
    let label = UILabel(frame: rect)

    label.backgroundColor = UIColor.clearColor()
    label.font = font
    label.textAlignment = .Center

    let defaults = NSUserDefaults.standardUserDefaults()

    label.textColor = defaults.stringForKey("TextColor") != nil
      ? UIColor(fromHex: defaults.stringForKey("TextColor"))
      : UIColor(fromHex: "30cec6")
    label.text = "\(self.angle)"

    return label
    }()

  lazy var minutesTitleLabel: UILabel = {
    let bounds = UIScreen.mainScreen().bounds
    let defaultSize = self.completedMode == true
      ? self.minuteTitleSize
      : self.minuteTitleSize * 0.9

    let fontSize = floor(defaultSize * CGRectGetWidth(self.frame)) / CGRectGetWidth(bounds)
    let font = HYPUtils.helveticaNeueUltraLightWithSize(fontSize)
    let minutesLeftText = NSLocalizedString("MINUTES LEFT", comment: "MINUTES LEFT")
    let attributes = [NSFontAttributeName : font]
    let textSize = (minutesLeftText as NSString).sizeWithAttributes(attributes)
    let factor: CGFloat = 5
    var yOffset: CGFloat = floor(factor * CGRectGetWidth(self.frame) / CGRectGetWidth(bounds))

    if UIScreen.andy_isPad() { yOffset -= 10 }

    let x: CGFloat = 0
    let y: CGFloat = CGRectGetMaxY(self.minutesValueLabel.frame) - yOffset
    let rect = CGRectMake(x, y, CGRectGetWidth(self.frame), textSize.height)
    let label = UILabel(frame: rect)

    label.backgroundColor = UIColor.clearColor()
    label.font = font
    label.text = minutesLeftText
    label.textAlignment = .Center

    let defaults = NSUserDefaults.standardUserDefaults()

    label.textColor = defaults.stringForKey("TextColor") != nil
      ? UIColor(fromHex: defaults.stringForKey("TextColor"))
      : UIColor(fromHex: "30cec6")

    return label
    }()

  lazy var attributedString: NSAttributedString = {
    var font: UIFont = HYPUtils.avenirLightWithSize(14)

    if UIScreen.andy_isPad() {
      font = HYPUtils.avenirLightWithSize(20)
    } else {
      if self.deviceHeight == 480 {
        font = HYPUtils.avenirLightWithSize(14)
      }  else if self.deviceHeight == 568 {
        font = HYPUtils.avenirLightWithSize(14)
      } else if self.deviceHeight == 667 {
          font = HYPUtils.avenirLightWithSize(16)
      } else if self.deviceHeight == 763 {
        font = HYPUtils.avenirLightWithSize(17)
      }
    }

    let attributes = [NSFontAttributeName : font, NSForegroundColorAttributeName: UIColor.whiteColor()]
    let string = NSAttributedString(string: self.title, attributes: attributes)

    return string
  }()

  lazy var firstQuadrandRect: CGRect = {
    let topMargin = CGRectGetMinX(self.frame)
    let rect = CGRectMake(CGRectGetMinX(self.circleRect) + CGRectGetWidth(self.circleRect) / 2.0,
      0 - topMargin,
      CGRectGetMaxX(self.circleRect),
      CGRectGetMinY(self.circleRect) + CGRectGetHeight(self.circleRect) / 2.0 + topMargin)
    return rect
  }()

  lazy var secondQuadrandRect: CGRect = {
    let topMargin = CGRectGetMinX(self.frame)
    let rect = CGRectMake(0.0,
      0.0 - topMargin,
      CGRectGetMinX(self.circleRect) + CGRectGetWidth(self.circleRect) / 2.0,
      CGRectGetMinY(self.circleRect) + CGRectGetHeight(self.circleRect) / 2.0 + topMargin)
    return rect
  }()

  init(frame: CGRect, completedMode: Bool) {
    self.completedMode = completedMode
    super.init(frame: frame)

    backgroundColor = UIColor.clearColor()
    addSubview(minutesValueLabel)

    if completedMode == true {
      addSubview(minutesTitleLabel)
      addSubview(hoursLabel)
    }

    minutesValueLabel.addObserver(self,
      forKeyPath: "text",
      options: .New,
      context: nil)
  }

  required public init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  deinit {
    self.minutesValueLabel.removeObserver(self, forKeyPath: "text")
    stopTimer()
  }

  override public func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    if (object as! NSObject).isEqual(minutesValueLabel) {
      var baseSize: CGFloat
      if count(minutesValueLabel.text!) == 5 {
        baseSize = UIScreen.andy_isPad() ? 200 : minuteValueSize
      } else if count(minutesValueLabel.text!) == 4 {
        baseSize = UIScreen.andy_isPad() ? 220 : 100
      } else {
        baseSize = UIScreen.andy_isPad() ? 280 : 120
      }

      if self.completedMode == true {
        baseSize = UIScreen.andy_isPad() ? 250 : minuteValueSize
      }

      let bounds = UIScreen.mainScreen().bounds
      let fontSize = floor(baseSize * CGRectGetWidth(frame) / CGRectGetWidth(bounds))
      minutesValueLabel.font = HYPUtils.helveticaNeueUltraLightWithSize(fontSize)
    }
  }

  override public func drawRect(rect: CGRect) {
    super.drawRect(rect)

    let context = UIGraphicsGetCurrentContext()
    let circleColor = colorForMinutesIndicator()
    let transform = CircleSizeFactor
    let sideMargin = floor(CGRectGetWidth(rect) * (1 - transform) / 2)
    let length = CGRectGetWidth(rect) * transform
    let circleRect = CGRectMake(sideMargin, sideMargin, length, length)

    drawCircle(context, color: circleColor, rect: circleRect)

    self.circleRect = circleRect

    if active == true {
      let radius = CGRectGetWidth(circleRect) / 2
      let minutesColor = UIColor.whiteColor()
      drawMinutes(context,
        color: minutesColor,
        radius: radius,
        angle: CGFloat(angle),
        containerRect: circleRect)

      let secondsColor = UIColor.whiteColor()
      if let timer = timer where timer.valid == true {
        let factor: CGFloat = self.completedMode == true ? 0.1 : 0.2
        drawSecondsIndicator(context, color: secondsColor, radius: sideMargin * factor, containerRect: circleRect)
      }

      if self.completedMode == true {
        drawText(context, rect: rect)
      }
    } else {
      let secondsColor = UIColor.whiteColor()
      drawSecondsIndicator(context, color: secondsColor, radius: sideMargin * 0.2, containerRect: circleRect)
    }
  }

  func drawCircle(context: CGContextRef, color: UIColor, rect: CGRect) {
    CGContextSaveGState(context)
    color.set()
    CGContextFillEllipseInRect(context, rect)
    CGContextRestoreGState(context)
  }

  func drawMinutes(context: CGContextRef, color: UIColor, radius: CGFloat, angle: CGFloat, containerRect: CGRect) {
    CGContextSaveGState(context)

    let angleTranslation: CGFloat = 0 - 90
    let π = CGFloat(M_PI)
    let startDeg: CGFloat = π * (0 + angleTranslation) / 180
    let endDeg: CGFloat = π * (angle + angleTranslation) / 180
    let x = CGRectGetWidth(containerRect) / 2 + containerRect.origin.x
    let y = CGRectGetWidth(containerRect) / 2 + containerRect.origin.y

    color.set()

    CGContextMoveToPoint(context, x, y)
    CGContextAddArc(context, x, y, radius, startDeg, endDeg, 0)
    CGContextClosePath(context)
    CGContextFillPath(context)
    CGContextRestoreGState(context)
  }

  func drawSecondsIndicator(context: CGContextRef, color: UIColor, radius: CGFloat, containerRect: CGRect) {
    let value = CGFloat(seconds) * 6.0
    let circleCenter = pointFromAngle(value, radius: radius, containerRect: containerRect)
    let circleRect = CGRectMake(circleCenter.x, circleCenter.y, radius * 2, radius * 2)
    CGContextSaveGState(context)
    color.set()
    CGContextFillEllipseInRect(context, circleRect)
    CGContextRestoreGState(context)
  }

  func drawText(context: CGContextRef, rect: CGRect) {
    var t0 = CGContextGetCTM(context)
    let xScaleFactor = t0.a > 0 ? t0.a : 0-t0.a
    let yScaleFactor = t0.a > 0 ? t0.d : 0-t0.d
    t0 = CGAffineTransformInvert(t0)

    if xScaleFactor != 1.0 || yScaleFactor != 1.0 {
      t0 = CGAffineTransformScale(t0, xScaleFactor, yScaleFactor)
    }

    CGContextConcatCTM(context, t0)
    CGContextSetTextMatrix(context, CGAffineTransformIdentity)
    let line = CTLineCreateWithAttributedString(attributedString)


    let glyphCount = CTLineGetGlyphCount(line)
    if glyphCount == 0 {
      return
    }

    struct GlyphArcInfo {
      var width: CGFloat
      var angle: CGFloat
    }

  }

  func pointFromAngle(angle: CGFloat, radius: CGFloat, containerRect: CGRect)  -> CGPoint {
    let centerPoint = CGPointMake(CGRectGetWidth(frame) / 2 - radius, CGRectGetHeight(frame) / 2 - radius)
    var result = CGPointMake(0.0,0.0)

    let π = CGFloat(M_PI)
    let angleTranslation: CGFloat = 0 - 90
    let magicFuckingNumber: CGFloat = CGRectGetWidth(containerRect) / 2
    result.x = centerPoint.x + magicFuckingNumber * cos(π * (angle + angleTranslation) / 180)
    result.y = centerPoint.x + magicFuckingNumber * sin(π * (angle + angleTranslation) / 180)

    return result
  }

  func colorForMinutesIndicator() -> UIColor {
    let color: UIColor
    let saturationBaseOffset: CGFloat = 0.10
    let saturationBase: CGFloat = 0.20
    let saturationBasedOnAngle: CGFloat = saturationBase * (CGFloat(angle)/360.0) + saturationBaseOffset

    let normalCircleColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.4)
    let calculatedColor = UIColor(hue: 255, saturation: saturationBasedOnAngle, brightness: 0.96, alpha: 1.0)
    let unactiveCircleColor = UIColor(white: 1.0, alpha: 0.4)

    if active == true {
      color = isHoursMode == true
        ? calculatedColor : normalCircleColor
    } else {
      color = unactiveCircleColor
    }

    return color
  }

  func shouldBlockTouchesForPoint(currentPoint: CGPoint) -> Bool {
    let xBlockCoordinate = CGRectGetWidth(frame) / 2
    let pointBelongsToFirstHalfOfTheScreen = currentPoint.x < xBlockCoordinate
    let lastPointIsZero: Bool = CGPointEqualToPoint(lastPoint, CGPointZero)
    let lastPointWasInFirstQuadrand: Bool = CGRectContainsPoint(self.firstQuadrandRect, lastPoint)

    if isHoursMode == false && pointBelongsToFirstHalfOfTheScreen == true &&
      (lastPointIsZero == false && lastPointWasInFirstQuadrand == true) {
      return true
    }

    return false
  }

  func handleTouchesForPoint(currentPoint: CGPoint) {
    evaluateMinutesUsingPoint(currentPoint)
    lastPoint = currentPoint
    sendActionsForControlEvents(.ValueChanged)
  }

  func pointIsInFirstQuadrand(point: CGPoint) -> Bool {
    let currentPointIsInFirstQuadrand = CGRectContainsPoint(firstQuadrandRect, point)
    let lastPointWasInFirstQuadrand = CGRectContainsPoint(firstQuadrandRect, lastPoint)
    let lastPointIsZero = CGPointEqualToPoint(lastPoint, CGPointZero)

    if currentPointIsInFirstQuadrand == true {
      if lastPointIsZero == false && lastPointWasInFirstQuadrand == true {
        return true
      }
    }

    return false
  }

  func pointIsComingFromSecondQuadrand(point: CGPoint) -> Bool {
    let currentPointIsInFirstQuadrand = CGRectContainsPoint(firstQuadrandRect, point)
    let lastPointWasInSecondQuadrand = CGRectContainsPoint(secondQuadrandRect, lastPoint)
    let lastPointIsZero = CGPointEqualToPoint(lastPoint, CGPointZero)

    if currentPointIsInFirstQuadrand == true {
      if lastPointIsZero == false && lastPointWasInSecondQuadrand == true {
        return true
      }
    }

    return false
  }

  func pointIsComingFromFirstQuadrand(point: CGPoint) -> Bool {
    let currentPointIsInSecondQuadrand = CGRectContainsPoint(secondQuadrandRect, point)
    let lastPointWasInFirstQuadrand = CGRectContainsPoint(firstQuadrandRect, lastPoint)
    let lastPointIsZero = CGPointEqualToPoint(lastPoint, CGPointZero)

    if currentPointIsInSecondQuadrand == true {
      if lastPointIsZero == false && lastPointWasInFirstQuadrand == true {
        return true
      }
    }

    return false
  }

  func playInputClick() {
    UIDevice.currentDevice().playInputClick()
  }

  func startAlarm() {
    let numberOfSeconds = angle / 6 * 60 + hours * 3600
    handleNotificationWithNumberOfSeconds(NSTimeInterval(numberOfSeconds))
    if alarm != nil {
      title = alarm!.timerTitle
    }
    setNeedsDisplay()
  }

  func startTimer() {
    if timer == nil {
      timer = NSTimer.scheduledTimerWithTimeInterval(1,
        target: self,
        selector: "updateSeconds:",
        userInfo: nil,
        repeats: true)
      NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
  }

  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

  func restartTimer() {
    angle = 0
    hours = 0
    minutes = 0
    seconds = 0
    sendActionsForControlEvents(.ValueChanged)
  }

  func updateSeconds(timer: NSTimer) {
    seconds -= 1
    if seconds < 0 {
      angle = minutes - 1 * 6
      seconds = 59
      minutes -= 1

      if minutes < 0 && hours > 0 {
        minutes = 59
        hours -= 1
      }

      sendActionsForControlEvents(.ValueChanged)
    }

    if seconds == 0 && minutes == 0 && hours == 0 {
      restartTimer()
      title = Alarm.messageForSetAlarm()
      stopTimer()
    }

    if minutes == -1 {
      restartTimer()
    }

    setNeedsDisplay()
  }

  func evaluateMinutesUsingPoint(currentPoint: CGPoint) {
    let centerPoint = CGPointMake(frame.width / 2, frame.height / 2)
    let currentAngle: Float = AngleFromNorth(centerPoint, currentPoint, true)
    let angle = floor(currentAngle)

    if pointIsComingFromSecondQuadrand(currentPoint) == true {
      hours += 1
    } else if isHoursMode == true && pointIsComingFromFirstQuadrand(currentPoint) == true {
      hours -= 1
    }

    self.minutes = Int(angle) / 6
    self.angle = Int(angle)
    setNeedsDisplay()
  }

  func cancelCurrentLocalNotification() {
    if let notification = LocalNotificationManager.existingNotificationWithAlarmID(alarmID!) {
      UIApplication.sharedApplication().cancelLocalNotification(notification)
    }
  }

  func handleNotificationWithNumberOfSeconds(numberOfSeconds: NSTimeInterval) {
    cancelCurrentLocalNotification()
    if numberOfSeconds > 0 {
      createNotificationUsingNumberOfSeconds(numberOfSeconds)
    }
  }

  func createNotificationUsingNumberOfSeconds(numberOfSeconds: NSTimeInterval) {
    seconds = 0
    startTimer()

    let title = NSLocalizedString("\(alarm!.title) just finished",
      comment: "\(alarm!.title) just finished")
    LocalNotificationManager.createNotification(numberOfSeconds,
      message: title,
      title: NSLocalizedString("View Details",
        comment: "View Details"),
      alarmID: alarmID!)
  }

  override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
    super.beginTrackingWithTouch(touch, withEvent: event)

    title = Alarm.messageForReleaseToSetAlarm()
    stopTimer()
    return true
  }

  override public func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
    super.continueTrackingWithTouch(touch, withEvent: event)
    let currentPoint = touch.locationInView(self)

    if touchesAreActive == true {
      if isHoursMode == false && shouldBlockTouchesForPoint(currentPoint) == true {
        touchesAreActive = false
        angle = 0
        setNeedsDisplay()
        return true
      } else {
        handleTouchesForPoint(currentPoint)
      }
    } else if pointIsComingFromSecondQuadrand(currentPoint) == true
      || pointIsInFirstQuadrand(currentPoint) == true {
        touchesAreActive = true
    }

    lastPoint = currentPoint

    return true
  }

  override public func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
    super.endTrackingWithTouch(touch, withEvent: event)

    let currentPoint = touch.locationInView(self)

    if (pointIsComingFromFirstQuadrand(currentPoint) && hours == 0) ||
      (angle == 0 && hours == 0) ||
      (minutes == 0 && hours == 0) {
        angle = 0
        touchesAreActive = false
        title = Alarm.messageForSetAlarm()
        cancelCurrentLocalNotification()
        setNeedsDisplay()
    } else {
      // add delay
      self.startAlarm()
    }

    lastPoint = CGPointZero
  }
}