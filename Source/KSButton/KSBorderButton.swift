//
//  KSBorderButton.swift
//  KSMediaPickerDemo
//
//  Created by kinsun on 2019/5/8.
//  Copyright © 2019年 kinsun. All rights reserved.
//

import UIKit

open class KSBorderButton: KSButton {
    
    private var _colors = {() -> [UIControl.State.RawValue: CGColor] in
        let state = UIControl.State.self
        return [state.normal.rawValue: UIColor.ks_white.cgColor,
                state.highlighted.rawValue: UIColor.ks_lightGray.cgColor,
                state.disabled.rawValue: UIColor.ks_lightGray.cgColor]
    }()
    
    @objc open func setBorderColor(_ borderColor: UIColor?, for state: UIControl.State) {
        if borderColor == nil {
            _colors.removeValue(forKey: state.rawValue)
            if self.state == state {
                layer.borderColor = UIColor.clear.cgColor
            }
        } else {
            let cgColor = borderColor!.cgColor
            _colors[state.rawValue] = cgColor
            if self.state == state {
                layer.borderColor = cgColor
            }
        }
    }
    
    @objc open func borderColor(for state: UIControl.State) -> UIColor? {
        if let color = _borderColor(for: state) {
            return UIColor(cgColor: color)
        } else {
            return nil
        }
    }
    
    private func _borderColor(for state: UIControl.State) -> CGColor? {
        return _colors[state.rawValue]
    }
    
    open override var isEnabled: Bool {
        didSet {
            layer.borderColor = _borderColor(for: state) ?? _borderColor(for: .normal)
        }
    }
    
    open override var isHighlighted: Bool {
        didSet {
            layer.borderColor = _borderColor(for: state) ?? _borderColor(for: .normal)
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            layer.borderColor = _borderColor(for: state) ?? _borderColor(for: .normal)
        }
    }

}
