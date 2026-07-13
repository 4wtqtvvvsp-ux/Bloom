//
//  ConditionIconImageProcessor.swift
//  うんち記録
//
//  アイコン素材内の #51515a（線色）だけを差し替え、他の色はそのままにする
//

import UIKit
import CoreGraphics

enum ConditionIconImageProcessor {
    /// デザイン上の線色（HTML #51515a）
    private static let targetR: Int = 0x51
    private static let targetG: Int = 0x51
    private static let targetB: Int = 0x5A

    /// Max RGB distance from #51515a to replace a pixel (includes blended edges).
    private static let matchDistance: Double = 52
    /// Downscale when longest side exceeds this (points) before scanning pixels.
    private static let maxProcessSide: CGFloat = 400

    static func imageReplacingLineColor(_ image: UIImage, with replacement: UIColor) -> UIImage? {
        let scaled = downscaleIfNeeded(image, maxSide: maxProcessSide)
        guard let cgImage = scaled.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var data = [UInt8](repeating: 0, count: height * bytesPerRow)

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        guard let context = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var rr: CGFloat = 0, rg: CGFloat = 0, rb: CGFloat = 0, ra: CGFloat = 0
        if !replacement.getRed(&rr, green: &rg, blue: &rb, alpha: &ra) {
            var w: CGFloat = 0
            guard replacement.getWhite(&w, alpha: &ra) else { return nil }
            rr = w
            rg = w
            rb = w
        }
        let nr = UInt8(max(0, min(255, rr * 255)))
        let ng = UInt8(max(0, min(255, rg * 255)))
        let nb = UInt8(max(0, min(255, rb * 255)))

        let tr = targetR, tg = targetG, tb = targetB
        let tol = matchDistance

        for y in 0..<height {
            let row = y * bytesPerRow
            for x in 0..<width {
                let i = row + x * bytesPerPixel
                let pa = Int(data[i + 3])
                if pa < 8 { continue }

                let pr = Int(data[i])
                let pg = Int(data[i + 1])
                let pb = Int(data[i + 2])

                let dr = Double(pr - tr)
                let dg = Double(pg - tg)
                let db = Double(pb - tb)
                let dist = (dr * dr + dg * dg + db * db).squareRoot()

                if dist <= tol {
                    data[i] = nr
                    data[i + 1] = ng
                    data[i + 2] = nb
                }
            }
        }

        guard let outContext = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ),
        let outCG = outContext.makeImage() else { return nil }

        return UIImage(cgImage: outCG, scale: scaled.scale, orientation: scaled.imageOrientation)
    }

    private static func downscaleIfNeeded(_ image: UIImage, maxSide: CGFloat) -> UIImage {
        let w = image.size.width
        let h = image.size.height
        let longest = max(w, h)
        guard longest > maxSide, longest > 0 else { return image }
        let scale = maxSide / longest
        let newSize = CGSize(width: w * scale, height: h * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
