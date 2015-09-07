import WatchKit
import Foundation
import WatchConnectivity

class TimerInterfaceController: WKInterfaceController {

  enum State {
    case Unknown, Active, Inactive
  }

  // MARK: - Root interface views

  @IBOutlet var activeGroup: WKInterfaceGroup!
  @IBOutlet var inactiveGroup: WKInterfaceGroup!
  
  @IBOutlet var button: WKInterfaceButton!

  // MARK: - Active group views

  @IBOutlet weak var minutesGroup: WKInterfaceGroup!
  @IBOutlet weak var secondsGroup: WKInterfaceGroup!
  @IBOutlet weak var minutesTextLabel: WKInterfaceLabel!
  @IBOutlet weak var hoursTextLabel: WKInterfaceLabel!
  @IBOutlet weak var minutesLabel: WKInterfaceLabel!

  // MARK: - Inactive group views

  @IBOutlet var hourPicker: WKInterfacePicker!
  @IBOutlet var hourLabel: WKInterfaceLabel!
  @IBOutlet var hourOutlineGroup: WKInterfaceGroup!

  @IBOutlet var minutePicker: WKInterfacePicker!
  @IBOutlet var minuteLabel: WKInterfaceLabel!
  @IBOutlet var minuteOutlineGroup: WKInterfaceGroup!

  // MARK: - Class variables

  var session : WCSession!
  var alarmTimer: AlarmTimer?
  var index = 0
  var pickerHours = 0
  var pickerMinutes = 0

  var state: State = .Unknown {
    didSet {
      switch state {
      case .Active:
        inactiveGroup.setHidden(true)
        activeGroup.setHidden(false)

        button.setTitle(NSLocalizedString("End timer", comment: ""))
        button.setHidden(false)
        button.setEnabled(true)
      case .Inactive:
        activeGroup.setHidden(true)
        inactiveGroup.setHidden(false)

        button.setTitle(NSLocalizedString("Start timer", comment: ""))
        button.setHidden(false)
        button.setEnabled(pickerHours > 0 || pickerMinutes > 0)

        minutePicker.setSelectedItemIndex(pickerMinutes)
        hourPicker.setSelectedItemIndex(pickerHours)

        hourPicker.resignFocus()
        minutePicker.resignFocus()
        minutePicker.focus()
      default:
        activeGroup.setHidden(true)
        inactiveGroup.setHidden(true)
        button.setHidden(true)
      }
    }
  }

  // MARK: - Lifecycle

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    if let context = context as? TimerContext {
      index = context.index
      setTitle(context.title)
      hourLabel.setText(NSLocalizedString("hr", comment: "").uppercaseString)
      minuteLabel.setText(NSLocalizedString("min", comment: "").uppercaseString)

      state = .Unknown
    }
  }

  override func willActivate() {
    super.willActivate()

    alarmTimer?.stop()
    setupPickers()

    if WCSession.isSupported() {
      session = WCSession.defaultSession()
      session.delegate = self
      session.activateSession()
    }

    sendMessage(Message(.GetAlarm))
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  override func pickerDidFocus(picker: WKInterfacePicker) {
    var location: Int

    if picker == minutePicker {
      hourOutlineGroup.setBackgroundImageNamed(ImageList.Timer.pickerOutline)
      minuteOutlineGroup.setBackgroundImageNamed(ImageList.Timer.pickerOutlineFocused)
      inactiveGroup.setBackgroundImageNamed(ImageList.Timer.pickerMinutes)

      location = pickerMinutes
    } else {
      minuteOutlineGroup.setBackgroundImageNamed(ImageList.Timer.pickerOutline)
      hourOutlineGroup.setBackgroundImageNamed(ImageList.Timer.pickerOutlineFocused)
      inactiveGroup.setBackgroundImageNamed(ImageList.Timer.pickerHours)

      location = pickerHours
    }

    inactiveGroup.startAnimatingWithImagesInRange(
      NSRange(location: location, length: 1),
      duration: 0, repeatCount: 1)
  }

  // MARK: - Actions

  @IBAction func hourPickerChanged(value: Int) {
    pickerHours = value
    inactiveGroup.startAnimatingWithImagesInRange(
      NSRange(location: value, length: 1),
      duration: 0, repeatCount: 1)
    button.setEnabled(pickerHours > 0 || pickerMinutes > 0)
    WKInterfaceDevice.currentDevice().playHaptic(.Click)
  }

  @IBAction func minutePickerChanged(value: Int) {
    pickerMinutes = value
    inactiveGroup.startAnimatingWithImagesInRange(
      NSRange(location: value, length: 1),
      duration: 0, repeatCount: 1)
    button.setEnabled(pickerHours > 0 || pickerMinutes > 0)
    WKInterfaceDevice.currentDevice().playHaptic(.Click)
  }

  @IBAction func buttonDidTap() {
    if state == .Active {
      WKInterfaceDevice.currentDevice().playHaptic(.Stop)
      button.setEnabled(false)
      sendMessage(Message(.CancelAlarm))
    } else {
      WKInterfaceDevice.currentDevice().playHaptic(.Start)
      let amount = pickerHours * 60 * 60 + pickerMinutes * 60
      button.setEnabled(false)
      pickerHours = 0
      pickerMinutes = 0
      sendMessage(Message(.UpdateAlarm, ["amount": amount]))
    }
  }

  @IBAction func menu3MinutesButtonDidTap() {
    WKInterfaceDevice.currentDevice().playHaptic(.Start)
    sendMessage(Message(.UpdateAlarm, ["amount": 3 * 60]))
  }
  
  @IBAction func menu5MinutesButtonDidTap() {
    WKInterfaceDevice.currentDevice().playHaptic(.Start)
    sendMessage(Message(.UpdateAlarm, ["amount": 5 * 60]))
  }

  // MARK: - Communication

  func sendMessage(var message: Message) {
    message.parameters["index"] = index

    session.sendMessage(message.data,
      replyHandler: { [weak self] response in
        if let weakSelf = self {
          if let alarmData = response["alarm"] as? [String: AnyObject] {
            weakSelf.alarmTimer?.stop()
            weakSelf.setupAlarm(alarmData)
          } else {
            weakSelf.state = .Inactive
          }
        }
      }, errorHandler: { error in
        print(error)
    })
  }

  // MARK: - Pickers

  func setupPickers() {
    let hourPickerItems: [WKPickerItem] = Array(0...12).map {
      let pickerItem = WKPickerItem()
      pickerItem.title = "\($0)"

      return pickerItem
    }

    hourPicker.setItems(hourPickerItems)

    let minutePickerItems: [WKPickerItem] = Array(0...59).map {
      let pickerItem = WKPickerItem()
      pickerItem.title = "\($0)"

      return pickerItem
    }

    minutePicker.setItems(minutePickerItems)
  }

  // MARK: - Plate

  func updatePlate(alarm: Alarm) {
    var hoursText = ""

    if alarm.active {
      if alarm.hours > 0 {
        hoursText = "\(alarm.hours) " + NSLocalizedString("hour", comment: "")
      }

      secondsGroup.setBackgroundImageNamed(ImageList.Timer.secondSequence)
      secondsGroup.startAnimatingWithImagesInRange(
        NSRange(location: 59 - alarm.seconds, length: 1),
        duration: 0, repeatCount: 1)
    } else {
      secondsGroup.setBackgroundImageNamed(nil)
    }

    minutesGroup.setBackgroundImageNamed(ImageList.Timer.minuteSequence)
    minutesGroup.startAnimatingWithImagesInRange(
      NSRange(location: alarm.minutes, length: 1),
      duration: 0, repeatCount: 1)

    minutesLabel.setText("\(alarm.minutes)")
    minutesTextLabel.setText(NSLocalizedString("minutes", comment: "").uppercaseString)
    hoursTextLabel.setText(hoursText.uppercaseString)
  }

  // MARK: - Alarms

  func setupAlarm(alarmInfo: [String: AnyObject]) {
    let alarm = Alarm(
      firedDate: alarmInfo["firedDate"] as? NSDate,
      numberOfSeconds: alarmInfo["numberOfSeconds"] as? NSNumber)

    state = alarm.active ? .Active : .Inactive
    updatePlate(alarm)

    if alarm.active {
      alarmTimer = AlarmTimer(alarms: [alarm], delegate: self)
      alarmTimer?.start()
    }
  }
}

// MARK: - WCSessionDelegate

extension TimerInterfaceController: WCSessionDelegate {

  func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
    alarmTimer?.stop()
    if let alarms = applicationContext["alarms"] as? [AnyObject],
      alarmData = alarms[index] as? [String: AnyObject] where alarms.count > index {
        setupAlarm(alarmData)
    }
  }
}

// MARK: - AlarmTimerDelegate

extension TimerInterfaceController: AlarmTimerDelegate {

  func alarmTimerDidTick(alarmTimer: AlarmTimer, alarms: [Alarm]) {
    if let alarm = alarms.first {
      updatePlate(alarm)
      if !alarm.active {
        alarmTimer.stop()
      }
    }
  }
}