/*
 
import UIKit

@objc public protocol TagListViewDelegate {
    @objc optional func tagPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void
    @objc optional func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void
}

@IBDesignable
open class TagListView: UIView {
    
    @IBInspectable open dynamic var textColor: UIColor = UIColor.white {
        didSet {
            for tagView in tagViews {
                tagView.textColor = textColor
            }
        }
    }
    
    @IBInspectable open dynamic var selectedTextColor: UIColor = UIColor.white {
        didSet {
            for tagView in tagViews {
                tagView.selectedTextColor = selectedTextColor
            }
        }
    }

    @IBInspectable open dynamic var tagLineBreakMode: NSLineBreakMode = .byTruncatingMiddle {
        didSet {
            for tagView in tagViews {
                tagView.titleLineBreakMode = tagLineBreakMode
            }
        }
    }
    
    @IBInspectable open dynamic var tagBackgroundColor: UIColor = UIColor.gray {
        didSet {
            for tagView in tagViews {
                tagView.tagBackgroundColor = tagBackgroundColor
            }
        }
    }
    
    @IBInspectable open dynamic var tagHighlightedBackgroundColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
            }
        }
    }
    
    @IBInspectable open dynamic var tagSelectedBackgroundColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.selectedBackgroundColor = tagSelectedBackgroundColor
            }
        }
    }
    
    @IBInspectable open dynamic var cornerRadius: CGFloat = 0 {
        didSet {
            for tagView in tagViews {
                tagView.cornerRadius = cornerRadius
            }
        }
    }
    @IBInspectable open dynamic var borderWidth: CGFloat = 0 {
        didSet {
            for tagView in tagViews {
                tagView.borderWidth = borderWidth
            }
        }
    }
    
    @IBInspectable open dynamic var borderColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.borderColor = borderColor
            }
        }
    }
    
    @IBInspectable open dynamic var selectedBorderColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.selectedBorderColor = selectedBorderColor
            }
        }
    }
    
    @IBInspectable open dynamic var paddingY: CGFloat = 2 {
        didSet {
            for tagView in tagViews {
                tagView.paddingY = paddingY
            }
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var paddingX: CGFloat = 5 {
        didSet {
            for tagView in tagViews {
                tagView.paddingX = paddingX
            }
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var marginY: CGFloat = 2 {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var marginX: CGFloat = 5 {
        didSet {
            rearrangeViews()
        }
    }
    
    @objc public enum Alignment: Int {
        case left
        case center
        case right
    }
    @IBInspectable open var alignment: Alignment = .left {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var shadowColor: UIColor = UIColor.white {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var shadowRadius: CGFloat = 0 {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var shadowOffset: CGSize = CGSize.zero {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var shadowOpacity: Float = 0 {
        didSet {
            rearrangeViews()
        }
    }
    
    @IBInspectable open dynamic var enableRemoveButton: Bool = false {
        didSet {
            for tagView in tagViews {
                tagView.enableRemoveButton = enableRemoveButton
            }
            rearrangeViews()
        }
    }
    
    @IBInspectable open dynamic var removeButtonIconSize: CGFloat = 12 {
        didSet {
            for tagView in tagViews {
                tagView.removeButtonIconSize = removeButtonIconSize
            }
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var removeIconLineWidth: CGFloat = 1 {
        didSet {
            for tagView in tagViews {
                tagView.removeIconLineWidth = removeIconLineWidth
            }
            rearrangeViews()
        }
    }
    
    @IBInspectable open dynamic var removeIconLineColor: UIColor = UIColor.white.withAlphaComponent(0.54) {
        didSet {
            for tagView in tagViews {
                tagView.removeIconLineColor = removeIconLineColor
            }
            rearrangeViews()
        }
    }
    
    @objc open dynamic var textFont: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            for tagView in tagViews {
                tagView.textFont = textFont
            }
            rearrangeViews()
        }
    }
    
    @IBOutlet open weak var delegate: TagListViewDelegate?
    
    open private(set) var tagViews: [TagView] = []
    private(set) var tagBackgroundViews: [UIView] = []
    private(set) var rowViews: [UIView] = []
    private(set) var tagViewHeight: CGFloat = 0
    private(set) var rows = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Interface Builder
    
    open override func prepareForInterfaceBuilder() {
        addTag("Welcome")
        addTag("to")
        addTag("TagListView").isSelected = true
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        rearrangeViews()
    }
    
    private func rearrangeViews() {
        let views = tagViews as [UIView] + tagBackgroundViews + rowViews
        for view in views {
            view.removeFromSuperview()
        }
        rowViews.removeAll(keepingCapacity: true)
        
        var currentRow = 0
        var currentRowView: UIView!
        var currentRowTagCount = 0
        var currentRowWidth: CGFloat = 0
        for (index, tagView) in tagViews.enumerated() {
            tagView.frame.size = tagView.intrinsicContentSize
            tagViewHeight = tagView.frame.height
            
            if currentRowTagCount == 0 || currentRowWidth + tagView.frame.width > frame.width {
                currentRow += 1
                currentRowWidth = 0
                currentRowTagCount = 0
                currentRowView = UIView()
                currentRowView.frame.origin.y = CGFloat(currentRow - 1) * (tagViewHeight + marginY)
                
                rowViews.append(currentRowView)
                addSubview(currentRowView)

                tagView.frame.size.width = min(tagView.frame.size.width, frame.width)
            }
            
            let tagBackgroundView = tagBackgroundViews[index]
            tagBackgroundView.frame.origin = CGPoint(x: currentRowWidth, y: 0)
            tagBackgroundView.frame.size = tagView.bounds.size
            tagBackgroundView.layer.shadowColor = shadowColor.cgColor
            tagBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: tagBackgroundView.bounds, cornerRadius: cornerRadius).cgPath
            tagBackgroundView.layer.shadowOffset = shadowOffset
            tagBackgroundView.layer.shadowOpacity = shadowOpacity
            tagBackgroundView.layer.shadowRadius = shadowRadius
            tagBackgroundView.addSubview(tagView)
            currentRowView.addSubview(tagBackgroundView)
            
            currentRowTagCount += 1
            currentRowWidth += tagView.frame.width + marginX
            
            switch alignment {
            case .left:
                currentRowView.frame.origin.x = 0
            case .center:
                currentRowView.frame.origin.x = (frame.width - (currentRowWidth - marginX)) / 2
            case .right:
                currentRowView.frame.origin.x = frame.width - (currentRowWidth - marginX)
            }
            currentRowView.frame.size.width = currentRowWidth
            currentRowView.frame.size.height = max(tagViewHeight, currentRowView.frame.height)
        }
        rows = currentRow
        
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Manage tags
    
    override open var intrinsicContentSize: CGSize {
        var height = CGFloat(rows) * (tagViewHeight + marginY)
        if rows > 0 {
            height -= marginY
        }
        return CGSize(width: frame.width, height: height)
    }
    
    private func createNewTagView(_ title: String) -> TagView {
        let tagView = TagView(title: title)
        
        tagView.textColor = textColor
        tagView.selectedTextColor = selectedTextColor
        tagView.tagBackgroundColor = tagBackgroundColor
        tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
        tagView.selectedBackgroundColor = tagSelectedBackgroundColor
        tagView.titleLineBreakMode = tagLineBreakMode
        tagView.cornerRadius = cornerRadius
        tagView.borderWidth = borderWidth
        tagView.borderColor = borderColor
        tagView.selectedBorderColor = selectedBorderColor
        tagView.paddingX = paddingX
        tagView.paddingY = paddingY
        tagView.textFont = textFont
        tagView.removeIconLineWidth = removeIconLineWidth
        tagView.removeButtonIconSize = removeButtonIconSize
        tagView.enableRemoveButton = enableRemoveButton
        tagView.removeIconLineColor = removeIconLineColor
        tagView.addTarget(self, action: #selector(tagPressed(_:)), for: .touchUpInside)
        tagView.removeButton.addTarget(self, action: #selector(removeButtonPressed(_:)), for: .touchUpInside)
        
        // On long press, deselect all tags except this one
        tagView.onLongPress = { [unowned self] this in
            for tag in self.tagViews {
                tag.isSelected = (tag == this)
            }
        }
        
        return tagView
    }

    @discardableResult
    open func addTag(_ title: String) -> TagView {
        return addTagView(createNewTagView(title))
    }
    
    @discardableResult
    open func addTags(_ titles: [String]) -> [TagView] {
        var tagViews: [TagView] = []
        for title in titles {
            tagViews.append(createNewTagView(title))
        }
        return addTagViews(tagViews)
    }
    
    @discardableResult
    open func addTagViews(_ tagViews: [TagView]) -> [TagView] {
        for tagView in tagViews {
            self.tagViews.append(tagView)
            tagBackgroundViews.append(UIView(frame: tagView.bounds))
        }
        rearrangeViews()
        return tagViews
    }

    @discardableResult
    open func insertTag(_ title: String, at index: Int) -> TagView {
        return insertTagView(createNewTagView(title), at: index)
    }
    
    @discardableResult
    open func addTagView(_ tagView: TagView) -> TagView {
        tagViews.append(tagView)
        tagBackgroundViews.append(UIView(frame: tagView.bounds))
        rearrangeViews()
        
        return tagView
    }

    @discardableResult
    open func insertTagView(_ tagView: TagView, at index: Int) -> TagView {
        tagViews.insert(tagView, at: index)
        tagBackgroundViews.insert(UIView(frame: tagView.bounds), at: index)
        rearrangeViews()
        
        return tagView
    }
    
    open func setTitle(_ title: String, at index: Int) {
        tagViews[index].titleLabel?.text = title
    }
    
    open func removeTag(_ title: String) {
        // loop the array in reversed order to remove items during loop
        for index in stride(from: (tagViews.count - 1), through: 0, by: -1) {
            let tagView = tagViews[index]
            if tagView.currentTitle == title {
                removeTagView(tagView)
            }
        }
    }
    
    open func removeTagView(_ tagView: TagView) {
        tagView.removeFromSuperview()
        if let index = tagViews.index(of: tagView) {
            tagViews.remove(at: index)
            tagBackgroundViews.remove(at: index)
        }
        
        rearrangeViews()
    }
    
    open func removeAllTags() {
        let views = tagViews as [UIView] + tagBackgroundViews
        for view in views {
            view.removeFromSuperview()
        }
        tagViews = []
        tagBackgroundViews = []
        rearrangeViews()
    }

    open func selectedTags() -> [TagView] {
        return tagViews.filter() { $0.isSelected == true }
    }
    
    // MARK: - Events
    
    @objc func tagPressed(_ sender: TagView!) {
        sender.onTap?(sender)
        delegate?.tagPressed?(sender.currentTitle ?? "", tagView: sender, sender: self)
    }
    
    @objc func removeButtonPressed(_ closeButton: CloseButton!) {
        if let tagView = closeButton.tagView {
            delegate?.tagRemoveButtonPressed?(tagView.currentTitle ?? "", tagView: tagView, sender: self)
        }
    }
}

 internal class CloseButton: UIButton {
 
 var iconSize: CGFloat = 10
 var lineWidth: CGFloat = 1
 var lineColor: UIColor = UIColor.white.withAlphaComponent(0.54)
 
 weak var tagView: TagView?
 
 override func draw(_ rect: CGRect) {
 let path = UIBezierPath()
 
 path.lineWidth = lineWidth
 path.lineCapStyle = .round
 
 let iconFrame = CGRect(
 x: (rect.width - iconSize) / 2.0,
 y: (rect.height - iconSize) / 2.0,
 width: iconSize,
 height: iconSize
 )
 
 path.move(to: iconFrame.origin)
 path.addLine(to: CGPoint(x: iconFrame.maxX, y: iconFrame.maxY))
 path.move(to: CGPoint(x: iconFrame.maxX, y: iconFrame.minY))
 path.addLine(to: CGPoint(x: iconFrame.minX, y: iconFrame.maxY))
 
 lineColor.setStroke()
 
 path.stroke()
 }
 
 }
 
 @IBDesignable
 open class TagView: UIButton {
 
 @IBInspectable open var cornerRadius: CGFloat = 0 {
 didSet {
 layer.cornerRadius = cornerRadius
 layer.masksToBounds = cornerRadius > 0
 }
 }
 @IBInspectable open var borderWidth: CGFloat = 0 {
 didSet {
 layer.borderWidth = borderWidth
 }
 }
 
 @IBInspectable open var borderColor: UIColor? {
 didSet {
 reloadStyles()
 }
 }
 
 @IBInspectable open var textColor: UIColor = UIColor.white {
 didSet {
 reloadStyles()
 }
 }
 @IBInspectable open var selectedTextColor: UIColor = UIColor.white {
 didSet {
 reloadStyles()
 }
 }
 @IBInspectable open var titleLineBreakMode: NSLineBreakMode = .byTruncatingMiddle {
 didSet {
 titleLabel?.lineBreakMode = titleLineBreakMode
 }
 }
 @IBInspectable open var paddingY: CGFloat = 2 {
 didSet {
 titleEdgeInsets.top = paddingY
 titleEdgeInsets.bottom = paddingY
 }
 }
 @IBInspectable open var paddingX: CGFloat = 5 {
 didSet {
 titleEdgeInsets.left = paddingX
 updateRightInsets()
 }
 }
 
 @IBInspectable open var tagBackgroundColor: UIColor = UIColor.gray {
 didSet {
 reloadStyles()
 }
 }
 
 @IBInspectable open var highlightedBackgroundColor: UIColor? {
 didSet {
 reloadStyles()
 }
 }
 
 @IBInspectable open var selectedBorderColor: UIColor? {
 didSet {
 reloadStyles()
 }
 }
 
 @IBInspectable open var selectedBackgroundColor: UIColor? {
 didSet {
 reloadStyles()
 }
 }
 
 var textFont: UIFont = UIFont.systemFont(ofSize: 12) {
 didSet {
 titleLabel?.font = textFont
 }
 }
 
 private func reloadStyles() {
 if isHighlighted {
 if let highlightedBackgroundColor = highlightedBackgroundColor {
 // For highlighted, if it's nil, we should not fallback to backgroundColor.
 // Instead, we keep the current color.
 backgroundColor = highlightedBackgroundColor
 }
 }
 else if isSelected {
 backgroundColor = selectedBackgroundColor ?? tagBackgroundColor
 layer.borderColor = selectedBorderColor?.cgColor ?? borderColor?.cgColor
 setTitleColor(selectedTextColor, for: UIControlState())
 }
 else {
 backgroundColor = tagBackgroundColor
 layer.borderColor = borderColor?.cgColor
 setTitleColor(textColor, for: UIControlState())
 }
 }
 
 override open var isHighlighted: Bool {
 didSet {
 reloadStyles()
 }
 }
 
 override open var isSelected: Bool {
 didSet {
 reloadStyles()
 }
 }
 
 // MARK: remove button
 
 let removeButton = CloseButton()
 
 @IBInspectable open var enableRemoveButton: Bool = false {
 didSet {
 removeButton.isHidden = !enableRemoveButton
 updateRightInsets()
 }
 }
 
 @IBInspectable open var removeButtonIconSize: CGFloat = 12 {
 didSet {
 removeButton.iconSize = removeButtonIconSize
 updateRightInsets()
 }
 }
 
 @IBInspectable open var removeIconLineWidth: CGFloat = 3 {
 didSet {
 removeButton.lineWidth = removeIconLineWidth
 }
 }
 @IBInspectable open var removeIconLineColor: UIColor = UIColor.white.withAlphaComponent(0.54) {
 didSet {
 removeButton.lineColor = removeIconLineColor
 }
 }
 
 /// Handles Tap (TouchUpInside)
 open var onTap: ((TagView) -> Void)?
 open var onLongPress: ((TagView) -> Void)?
 
 // MARK: - init
 
 required public init?(coder aDecoder: NSCoder) {
 super.init(coder: aDecoder)
 
 setupView()
 }
 
 public init(title: String) {
 super.init(frame: CGRect.zero)
 setTitle(title, for: UIControlState())
 
 setupView()
 }
 
 private func setupView() {
 titleLabel?.lineBreakMode = titleLineBreakMode
 
 frame.size = intrinsicContentSize
 addSubview(removeButton)
 removeButton.tagView = self
 
 let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
 self.addGestureRecognizer(longPress)
 }
 
 @objc func longPress() {
 onLongPress?(self)
 }
 
 // MARK: - layout
 
 override open var intrinsicContentSize: CGSize {
 var size = titleLabel?.text?.size(withAttributes: [NSAttributedStringKey.font: textFont]) ?? CGSize.zero
 size.height = textFont.pointSize + paddingY * 2
 size.width += paddingX * 2
 if size.width < size.height {
 size.width = size.height
 }
 if enableRemoveButton {
 size.width += removeButtonIconSize + paddingX
 }
 return size
 }
 
 private func updateRightInsets() {
 if enableRemoveButton {
 titleEdgeInsets.right = paddingX  + removeButtonIconSize + paddingX
 }
 else {
 titleEdgeInsets.right = paddingX
 }
 }
 
 open override func layoutSubviews() {
 super.layoutSubviews()
 if enableRemoveButton {
 removeButton.frame.size.width = paddingX + removeButtonIconSize + paddingX
 removeButton.frame.origin.x = self.frame.width - removeButton.frame.width
 removeButton.frame.size.height = self.frame.height
 removeButton.frame.origin.y = 0
 }
 }
 }

 
 
 
 */
