////
///  OnboardingHeaderView.swift
//

public class OnboardingHeaderView: UIView {
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultBoldFont(18)
        label.numberOfLines = 0
        return label
    }()

    lazy var messageLabel: ElloSizeableLabel = {
        let label = ElloSizeableLabel()
        label.font = UIFont.defaultFont()
        label.numberOfLines = 0
        return label
    }()

    var header: String {
        get { return headerLabel.text ?? "" }
        set {
            headerLabel.text = newValue
            setNeedsLayout()
        }
    }

    var message: String {
        get { return messageLabel.text ?? "" }
        set {
            messageLabel.setLabelText(newValue, color: .greyA())
            setNeedsLayout()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerLabel)
        addSubview(messageLabel)
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        let labelWidth = self.frame.width - 30
        headerLabel.frame = CGRect(x: 15, y: 24, width: labelWidth, height: 0)
        headerLabel.sizeToFit()

        messageLabel.frame = CGRect(x: 15, y: headerLabel.frame.maxY + 25, width: labelWidth, height: 0)
        messageLabel.sizeToFit()
    }

    override public func sizeToFit() {
        super.sizeToFit()
        layoutIfNeeded()
        frame.size.height = intrinsicContentSize().height
    }

    override public func intrinsicContentSize() -> CGSize {
        layoutIfNeeded()
        return CGSize(width: frame.width, height: messageLabel.frame.maxY + 15)
    }

}
