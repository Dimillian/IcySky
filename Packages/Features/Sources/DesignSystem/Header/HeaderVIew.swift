import SwiftUI

public struct HeaderTitleShadowModifier: ViewModifier {
  public init() {}

  public func body(content: Content) -> some View {
    content
      .foregroundStyle(
        .primary.shadow(
          .inner(
            color: .shadowSecondary.opacity(0.5),
            radius: 1, x: -1, y: -1))
      )
      .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 1)
  }
}

extension View {
  public func headerTitleShadow() -> some View {
    modifier(HeaderTitleShadowModifier())
  }
}

public enum HeaderType {
  case navigation  // Back button (chevron.backward)
  case modal  // Close button (xmark)
  case titleOnly  // No action button
  case custom(systemImage: String, action: () -> Void)  // Custom button
}

public enum HeaderFontSize {
  case title
  case largeTitle

  var font: Font {
    switch self {
    case .title: return .title
    case .largeTitle: return .largeTitle
    }
  }
}

public struct HeaderView: View {
  @Environment(\.dismiss) var dismiss
  let title: String
  let subtitle: String?
  let type: HeaderType
  let fontSize: HeaderFontSize
  let alignment: HorizontalAlignment

  // Legacy initializer for backward compatibility
  public init(
    title: String,
    subtitle: String? = nil,
    showBack: Bool = true
  ) {
    self.title = title
    self.subtitle = subtitle
    self.type = showBack ? .navigation : .titleOnly
    self.fontSize = .title
    self.alignment = .leading
  }

  // New initializer with enhanced options
  public init(
    title: String,
    subtitle: String? = nil,
    type: HeaderType = .navigation,
    fontSize: HeaderFontSize = .title,
    alignment: HorizontalAlignment = .leading
  ) {
    self.title = title
    self.subtitle = subtitle
    self.type = type
    self.fontSize = fontSize
    self.alignment = alignment
  }

  private var paddingForType: CGFloat {
    switch type {
    case .navigation, .titleOnly:
      return 0  // Original behavior - no horizontal padding
    case .modal, .custom:
      return 16  // New modal/custom headers get padding
    }
  }

  public var body: some View {
    HStack(alignment: .center) {
      switch type {
      case .titleOnly:
        EmptyView()
      case .navigation:
        actionButton
      case .modal, .custom:
        actionButton
          .padding(.trailing, 12)
      }

      // Title section
      titleSection

      Spacer()
    }
    .headerTitleShadow()
    .font(fontSize.font)
    .fontWeight(.bold)
    .listRowSeparator(.hidden)
    .padding(.horizontal, paddingForType)
    .padding(.vertical, fontSize == .largeTitle ? 16 : 8)
  }

  @ViewBuilder
  private var titleSection: some View {
    VStack(alignment: alignment, spacing: 4) {
      Text(title)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
      if let subtitle {
        Text(subtitle)
          .foregroundStyle(.secondary)
          .font(.callout)
          .lineLimit(1)
          .minimumScaleFactor(0.5)
      }
    }
    .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
  }

  @ViewBuilder
  private var actionButton: some View {
    switch type {
    case .navigation:
      Button {
        dismiss()
      } label: {
        Image(systemName: "chevron.backward")
          .id("back")
      }
      .buttonStyle(.plain)

    case .modal:
      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .font(.body)
          .padding(.all, 12)
      }
      .buttonStyle(.glass)
      .foregroundColor(.primary)

    case .custom(let systemImage, let action):
      Button {
        action()
      } label: {
        Image(systemName: systemImage)
          .font(.body)
          .padding(.all, 8)
      }
      .buttonStyle(.glass)
      .foregroundColor(.primary)

    case .titleOnly:
      EmptyView()
    }
  }
}

#Preview("Navigation Header") {
  HeaderView(
    title: "Navigation Title",
    subtitle: "Optional subtitle",
    type: .navigation
  )
  .padding()
}

#Preview("Modal Header") {
  HeaderView(
    title: "Modal Title",
    type: .modal
  )
  .padding()
}

#Preview("Title Only") {
  HeaderView(
    title: "Title Only Header",
    subtitle: "No action buttons",
    type: .titleOnly
  )
  .padding()
}

#Preview("Custom Header") {
  HeaderView(
    title: "Custom Action",
    subtitle: "With gear icon",
    type: .custom(systemImage: "gear") {
      print("Custom action tapped")
    }
  )
  .padding()
}

#Preview("Large Title") {
  HeaderView(
    title: "Large Title Header",
    subtitle: "Bigger font size",
    type: .navigation,
    fontSize: .largeTitle
  )
  .padding()
}

#Preview("Center Aligned") {
  HeaderView(
    title: "Centered Title",
    subtitle: "Center alignment",
    type: .modal,
    fontSize: .title,
    alignment: .center
  )
  .padding()
}

#Preview("All Configurations") {
  VStack(spacing: 20) {
    HeaderView(title: "Navigation", type: .navigation)
    Divider()
    HeaderView(title: "Modal", type: .modal)
    Divider()
    HeaderView(title: "Title Only", type: .titleOnly)
    Divider()
    HeaderView(
      title: "Custom",
      type: .custom(systemImage: "star") {}
    )
    Divider()
    HeaderView(
      title: "Large Title",
      type: .titleOnly,
      fontSize: .largeTitle
    )
  }
  .padding()
}
