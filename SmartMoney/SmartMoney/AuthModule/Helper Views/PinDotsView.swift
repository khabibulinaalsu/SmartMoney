import UIKit

class PinDotsView: UIView {
    private var dots: [UIView] = []
    private let spacing: CGFloat = 10
    private let dotSize: CGFloat = 15
    
    init(totalDots: Int) {
        super.init(frame: .zero)
        setupDots(count: totalDots)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDots(count: Int) {
        for _ in 0..<count {
            let dot = createDot()
            dots.append(dot)
            addSubview(dot)
        }
    }
    
    private func createDot() -> UIView {
        let dot = UIView()
        dot.layer.cornerRadius = dotSize / 2
        dot.layer.borderWidth = 1
        dot.layer.borderColor = UIColor.darkGray.cgColor
        dot.backgroundColor = .clear
        dot.translatesAutoresizingMaskIntoConstraints = false
        return dot
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let totalWidth = CGFloat(dots.count) * dotSize + CGFloat(dots.count - 1) * spacing
        var xOffset = (bounds.width - totalWidth) / 2
        
        for dot in dots {
            dot.frame = CGRect(x: xOffset, y: (bounds.height - dotSize) / 2, width: dotSize, height: dotSize)
            xOffset += dotSize + spacing
        }
    }
    
    func fillDot(at index: Int) {
        guard index >= 0 && index < dots.count else { return }
        dots[index].backgroundColor = .darkGray
    }
    
    func clearDot(at index: Int) {
        guard index >= 0 && index < dots.count else { return }
        dots[index].backgroundColor = .clear
    }
    
    func clearAllDots() {
        for dot in dots {
            dot.backgroundColor = .clear
        }
    }
}
