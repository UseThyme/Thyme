import UIKit

public class PlateCell: UICollectionViewCell {

  public lazy var timerControl: TimerControl = { [unowned self] in
    let frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
    let timerControl = TimerControl(frame: frame, completedMode: false)

    timerControl.userInteractionEnabled = false
    timerControl.backgroundColor = UIColor.clearColor()

    return timerControl
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(timerControl)
  }

  public required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
