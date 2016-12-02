/**
 * Tae Won Ha - http://taewon.de - @hataewon
 * See LICENSE
 */

import Cocoa
import PureLayout
import CocoaFontAwesome

/**
 This class is the base class for inner toolbars for workspace tools. It's got two default buttons:
 - Close button
 - Cog button: not shown when there's no menu
 */
class InnerToolBar: NSView, NSUserInterfaceValidations {

  static fileprivate let separatorColor = NSColor.controlShadowColor
  static fileprivate let separatorThickness = CGFloat(1)
  static fileprivate let iconDimension = CGFloat(19)
  static fileprivate let height = InnerToolBar.iconDimension + 2 + 2 + InnerToolBar.separatorThickness

  static fileprivate let backgroundColor = NSColor(red: 0.899, green: 0.934, blue: 0.997, alpha: 1)

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  fileprivate let closeButton = NSButton(forAutoLayout:())
  fileprivate let cogButton = NSPopUpButton(forAutoLayout:())

  fileprivate let locToSelector: [WorkspaceBarLocation: Selector] = [
    .top: #selector(InnerToolBar.moveToTopAction(_:)),
    .right: #selector(InnerToolBar.moveToRightAction(_:)),
    .bottom: #selector(InnerToolBar.moveToBottomAction(_:)),
    .left: #selector(InnerToolBar.moveToLeftAction(_:)),
  ]

  // MARK: - API

  var customMenu: NSMenu?
  var tool: WorkspaceTool?

  override var intrinsicContentSize: CGSize {
    if #available(macOS 10.11, *) {
      return CGSize(width: NSViewNoIntrinsicMetric, height: InnerToolBar.height)
    } else {
      return CGSize(width: -1, height: InnerToolBar.height)
    }
  }

  override init(frame: NSRect) {
    super.init(frame: frame)

    self.cogButton.configureForAutoLayout()

    // Because other views also want layer, this view also must want layer. Otherwise the z-index ordering is not set
    // correctly: views w/ wantsLayer = false are behind views w/ wantsLayer = true even when added later.
    self.wantsLayer = true
    self.layer?.backgroundColor = InnerToolBar.backgroundColor.cgColor

    self.addViews()
  }

  override func draw(_ dirtyRect: NSRect) {
    InnerToolBar.separatorColor.set()
    let bottomSeparatorRect = self.bottomSeparatorRect()
    if dirtyRect.intersects(bottomSeparatorRect) {
      NSRectFill(bottomSeparatorRect)
    }

    let innerSeparatorRect = self.innerSeparatorRect()
    if dirtyRect.intersects(innerSeparatorRect) {
      NSRectFill(innerSeparatorRect)
    }
  }

  fileprivate func configureToStandardIconButton(button: NSButton, image: NSImage?) {
    button.imagePosition = .imageOnly
    button.image = image
    button.isBordered = false

    // The following disables the square appearing when pushed.
    let cell = button.cell as? NSButtonCell
    cell?.highlightsBy = .contentsCellMask
  }

  fileprivate func addViews() {
    let close = self.closeButton
    let cog = self.cogButton

    let closeIcon = NSImage.fontAwesomeIcon(code: "fa-times-circle",
                                            textColor: .darkGray,
                                            dimension: InnerToolBar.iconDimension)
    let cogIcon = NSImage.fontAwesomeIcon(name: .cog,
                                          textColor: .darkGray,
                                          dimension: InnerToolBar.iconDimension)

    self.configureToStandardIconButton(button: close, image: closeIcon)

    cog.imagePosition = .imageOnly
    cog.pullsDown = true
    cog.isBordered = false

    let cogCell = cog.cell as? NSPopUpButtonCell
    cogCell?.arrowPosition = .noArrow

    let cogMenu = NSMenu()

    let cogMenuItem = NSMenuItem(title: "Cog", action: nil, keyEquivalent: "")
    cogMenuItem.image = cogIcon

    let moveToMenu = NSMenu()
    let topMenuItem = NSMenuItem(title: "Top",
                                 action: #selector(InnerToolBar.moveToTopAction(_:)),
                                 keyEquivalent: "")
    topMenuItem.target = self
    let rightMenuItem = NSMenuItem(title: "Right",
                                   action: #selector(InnerToolBar.moveToRightAction(_:)),
                                   keyEquivalent: "")
    rightMenuItem.target = self
    let bottomMenuItem = NSMenuItem(title: "Bottom",
                                    action: #selector(InnerToolBar.moveToBottomAction(_:)),
                                    keyEquivalent: "")
    bottomMenuItem.target = self
    let leftMenuItem = NSMenuItem(title: "Left",
                                  action: #selector(InnerToolBar.moveToLeftAction(_:)),
                                  keyEquivalent: "")
    leftMenuItem.target = self
    moveToMenu.addItem(leftMenuItem)
    moveToMenu.addItem(rightMenuItem)
    moveToMenu.addItem(bottomMenuItem)
    moveToMenu.addItem(topMenuItem)

    let moveToMenuItem = NSMenuItem(
      title: "Move To",
      action: nil,
      keyEquivalent: ""
    )
    moveToMenuItem.submenu = moveToMenu

    cogMenu.addItem(cogMenuItem)
    cogMenu.addItem(moveToMenuItem)

    cog.menu = cogMenu

    self.addSubview(close)
    self.addSubview(cog)

    close.autoPinEdge(toSuperviewEdge: .top, withInset: 2)
    close.autoPinEdge(toSuperviewEdge: .right, withInset: 2)

    cog.autoPinEdge(.right, to: .left, of: close, withOffset: 5)
    cog.autoPinEdge(toSuperviewEdge: .top, withInset: -1)
  }

  fileprivate func bottomSeparatorRect() -> CGRect {
    let bounds = self.bounds
    return CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: InnerToolBar.separatorThickness)
  }

  fileprivate func innerSeparatorRect() -> CGRect {
    let cogBounds = self.cogButton.frame
    let bounds = self.bounds
    return CGRect(x: cogBounds.minX + 6, y: bounds.minY + 4, width: 1, height: bounds.height - 4 - 4)
  }
}

// MARK: - Actions
extension InnerToolBar {

  func moveToTopAction(_ sender: Any?) {

  }

  func moveToRightAction(_ sender: Any?) {

  }

  func moveToBottomAction(_ sender: Any?) {

  }

  func moveToLeftAction(_ sender: Any?) {

  }
}

// MARK: - NSUserInterfaceValidations
extension InnerToolBar {

  func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
    guard let loc = self.tool?.location else {
      return true
    }

    if item.action == self.locToSelector[loc] {
      return false
    }

    return true
  }
}
