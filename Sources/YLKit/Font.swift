//
//  Font.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/11/22.
//


import AppKit

/// 极细
public func UltraLightFont(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size, weight: .ultraLight) }
/// 纤细
public func ThinFont(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size, weight: .thin) }
/// 细体
public func LightFont(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size, weight: .light) }
/// 默认
public func Font(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size) }
/// 中等
public func MediumFont(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size, weight: .medium) }
/// 半粗体
public func SemiboldFont(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size, weight: .semibold) }
/// 粗体
public func BoldFont(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size, weight: .bold) }
/// 特粗
public func HeavyFont(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size, weight: .heavy) }
/// 极粗
public func BlackFont(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size, weight: .black) }

/// 苹方-极细
public func UltralightFont(pingFang size: CGFloat) -> NSFont { NSFont(name: "PingFangSC-Ultralight", size: size) ?? UltraLightFont(size) }
/// 苹方-纤细
public func ThinFont(pingFang size: CGFloat) -> NSFont { NSFont(name: "PingFangSC-Thin", size: size) ?? ThinFont(size) }
/// 苹方-细体
public func LightFont(pingFang size: CGFloat) -> NSFont { NSFont(name: "PingFangSC-Light", size: size) ?? LightFont(size) }
/// 苹方-正常-默认
public func Font(pingFang size: CGFloat) -> NSFont { NSFont(name: "PingFangSC-Regular", size: size) ?? Font(size) }
/// 苹方-中等
public func MediumFont(pingFang size: CGFloat) -> NSFont { NSFont(name: "PingFangSC-Medium", size: size) ?? MediumFont(size) }
/// 苹方-半粗体（最粗）
public func BoldFont(pingFang size: CGFloat) -> NSFont { NSFont(name: "PingFangSC-Semibold", size: size) ?? SemiboldFont(size) }

