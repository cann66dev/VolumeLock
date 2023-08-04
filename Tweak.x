/*
 * Tweak.x
 * VolumeLock
 *
 * Created by Cann66 on 25/07/2023.
 */
#define LD_DEBUG NO

  static BOOL toggleVolumeLock = NO;


%hook SpringBoard
  -(BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)event {
    BOOL upPressed = NO;
    BOOL downPressed = NO;

    for(UIPress *press in event.allPresses.allObjects) {
      if(press.type == 102 && press.force == 1) {
        upPressed = YES;
      }
      if(press.type == 103 && press.force == 1) {
        downPressed = YES;
      }
    }

    if(upPressed && downPressed) {
      UINotificationFeedbackGenerator *feedback = [[UINotificationFeedbackGenerator alloc] init];
      [feedback prepare];

      switch ((int)toggleVolumeLock) {
        case 0:
        toggleVolumeLock = YES;
        [feedback notificationOccurred:UINotificationFeedbackTypeSuccess];
        break;

        case 1:
        toggleVolumeLock = NO;
        [feedback notificationOccurred:UINotificationFeedbackTypeError];
        break;
      }
    }

    return %orig;
  }
%end

%hook VolumeControl
  -(void)increaseVolume {
    if(toggleVolumeLock) {
      UINotificationFeedbackGenerator *feedback = [[UINotificationFeedbackGenerator alloc] init];
      [feedback notificationOccurred:UINotificationFeedbackTypeWarning];
      return ;
    }

    %orig;
  }

  -(void)decreaseVolume {
    if(toggleVolumeLock) {
      UINotificationFeedbackGenerator *feedback = [[UINotificationFeedbackGenerator alloc] init];
      [feedback notificationOccurred:UINotificationFeedbackTypeWarning];
      return ;
    }

    %orig;
  }
%end

%ctor {
  if([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){13, 0, 0}]) {
    %init(VolumeControl = NSClassFromString(@"SBVolumeControl"));
  }
}