import Foundation

extension Date {
  public var relativeFormatted: String {
    let aDay: TimeInterval = 60 * 60 * 24
    let isOlderThanADay = Date().timeIntervalSince(self) >= aDay
    if isOlderThanADay {
      return DateFormatterCache.shared.createdAtRelativeFormatter.localizedString(
        for: self,
        relativeTo: Date())
    } else {
      return Duration.seconds(-self.timeIntervalSinceNow).formatted(
        .units(
          width: .narrow,
          maximumUnitCount: 1))
    }
  }
}
