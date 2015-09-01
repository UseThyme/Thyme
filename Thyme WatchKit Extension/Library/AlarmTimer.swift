import Foundation

protocol AlarmTimerDelegate: class {

  func alarmTimerDidTick(alarmTimer: AlarmTimer, alarms: [Alarm])
}

class AlarmTimer: NSObject {

  var timer: NSTimer?
  var alarms = [Alarm]()
  weak var delegate: AlarmTimerDelegate?

  // MARK: - Initialization

  init(alarms: [Alarm], delegate: AlarmTimerDelegate? = nil) {
    self.alarms = alarms
    self.delegate = delegate
  }

  deinit {
    stop()
  }

  // MARK: - Timer

  func start() {
    if timer == nil {
      dispatch_async(dispatch_get_main_queue()) {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1,
          target: self,
          selector: "update:",
          userInfo: nil,
          repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
      }
    }
  }

  func stop() {
    dispatch_async(dispatch_get_main_queue()) {
      self.timer?.invalidate()
      self.timer = nil
    }
  }

  // MARK: - Actions

  func update(timer: NSTimer) {
    for alarm in alarms { alarm.update() }

    delegate?.alarmTimerDidTick(self, alarms: alarms)
  }
}
