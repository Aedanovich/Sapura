RCRTimers
=========

iOS timers that can be used to run code at regular intervals.

Note that timers only execute while your app is running in the foreground.

## What it Depends on

`RCRTimers` has been verified as working with Xcode 6.1 and iOS 8.1.

All code uses ARC.

## How to Use it

`RCRTimers` currently ships with three timers:

- `RCRSecondChangeTimer`
- `RCRMinuteChangeTimer`
- `RCRHourChangeTimer`

Each of the timers does its best to synchronize with the clock, firing when the second, minute, and hour change, respectively.

In order to use any of the timers, first add the `RCRTimers` folder and code to your project.

Then, one way to quickly setup a timer from a view controller would be as follows. In this example we’ll work with a `RCRMinuteChangeTimer`.

Import `RCRMinuteChangeTimer.h` into your view controller:

```objc
#import "RCRMinuteChangeTimer.h"
```

Next, add a property for the timer:

```objc
@property (nonatomic, strong) RCRMinuteChangeTimer *minuteChangeTimer;
```

Then, in your `viewDidLoad` method, initialize the timer, passing it a block of code to call each time it fires. For example:

```objc
self.minuteChangeTimer = [RCRMinuteChangeTimer timerWithBlock:^(NSDate *firingDate) {
    NSLog(@"RCRMinuteChangeTimer firing");
}];
```

In this case we’re simply logging a message using `NSLog()`, which will be output to the console every time the minute ticks over.

In order to stop a timer, preventing it from executing the block any further, call the `stop` method as follows:

```objc
[self.minuteChangeTimer stop];
```

Note that a stopped timer cannot be restarted. Instead, a new timer should be created instead to achieve the same effect.

Further examples and full documentation comments can be found in the sample project.

## Sample Project

A sample project containing several examples of timers can be found in the `RCRTimersSample` folder.

## API Docs

The [latest API documentation](http://cocoadocs.org/docsets/RCRTimers/) can be found on CocoaDocs.

## License

MIT License (see `LICENSE` in the root of the repository).