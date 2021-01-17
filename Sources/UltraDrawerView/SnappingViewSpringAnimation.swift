import CoreGraphics


internal final class SnappingViewSpringAnimation: SnappingViewAnimation {
    
    init(
        initialOrigin: CGFloat,
        targetOrigin: CGFloat,
        initialVelocity: CGFloat,
        onUpdate: @escaping (CGFloat) -> Void,
        completion: @escaping (Bool) -> Void
    ) {
        self.currentOrigin = initialOrigin
        self.currentVelocity = initialVelocity
        self.targetOrigin = targetOrigin
        self.onUpdate = onUpdate
        self.completion = completion
        
        updateAnimation()
    }
    
    func invalidate() {
        animation?.invalidate()
    }
    
    // MARK: - SnappingViewAnimation
    
    var targetOrigin: CGFloat {
        didSet {
            updateAnimation()
        }
    }
    
    var isDone: Bool {
        return animation?.running ?? false
    }
    
    // MARK: - Private
    
    private var currentOrigin: CGFloat
    private var currentVelocity: CGFloat
    private let onUpdate: (CGFloat) -> Void
    private let completion: (Bool) -> Void
    private var animation: TimerAnimation?
    
    private func updateAnimation() {
        guard !isDone else { return }
        
        animation?.invalidate(withColmpletion: false)
        
        let from = currentOrigin
        let to = targetOrigin
    
        let parameters = SpringTimingParameters(
            spring: .default,
            displacement: from - to,
            initialVelocity: currentVelocity,
            threshold: 1 / UIScreen.main.scale
        )
        
        let duration = parameters.duration
    
        animation = TimerAnimation(
            duration: duration,
            animations: { [weak self] _, time in
                guard let self = self else { return }
                self.currentOrigin = to + parameters.value(at: time)
                self.onUpdate(self.currentOrigin)
            },
            completion: completion
        )
    }
}
