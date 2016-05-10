RCRTimeLabel
============

An iOS `UILabel` subclass that simply displays the current date/time and keeps itself up to date.

## What it Depends on

`RCRTimeLabel` has been verified as working with Xcode 6.1 and iOS 8.1.

Additionally, `RCRTimeLabel` depends on [`RCRTimers`](https://github.com/robinsonrc/RCRTimers). If installing via CocoaPods you will get `RCRTimers` automatically.

All code uses ARC.

## How to Use it

Firstly, if you are not installing via CocoaPods you will need to obtain [`RCRTimers`](https://github.com/robinsonrc/RCRTimers) and add it to your project. If you are using CocoaPods this dependency will be satisfied automatically and there is nothing you need to do here.

Next, add the `RCRTimeLabel` folder and code to your project.

You can then use the label programmatically or via Interface Builder as you would any other `UILabel` - the only real difference being that this label will display the current date/time and will keep itself up to date, updating its text as time passes.

Assuming you're using Interface Builder, you can simply drag a regular `UILabel` out into your view and then customize it, specify its font, and so on, as you normally would.

Then, using the Identity Inspector, set the label’s class to be `RCRTimeLabel`.

In the simplest case, that's it - you're done! By default the label will present itself using `NSDateFormatterStyle` values of `NSDateFormatterNoStyle` and `NSDateFormatterShortStyle` for date and time respectively.

If you would prefer to provide a custom style for the date or time, you can do so by specifying values for the label’s `dateStyle` and `timeStyle` properties via the User Defined Runtime Attributes section of the Identity Inspector. Note that you’ll need to enter numeric values that correspond to the `NSDateFormatterStyle` enumeration when doing this.

Examples of the default label and labels with custom date and time styles can be seen in the sample project.

## Sample Project

A sample project demonstrating several examples of using the label can be found in the `RCRTimeLabelSample` folder.

## API Docs

The [latest API documentation](http://cocoadocs.org/docsets/RCRTimeLabel/) can be found on CocoaDocs.

## License

MIT License (see `LICENSE` in the root of the repository).
