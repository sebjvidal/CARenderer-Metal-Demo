//
//  CARenderer-Metal-Demo.swift
//  Snippet
//
//  Created by Seb Vidal on 23/02/2024.
//

import Metal
import QuartzCore

extension NSView {
    func renderWithCARenderer(completion: @escaping (_ image: NSImage) -> Void) {
        let width: Int = Int(frame.width * 2)
        let height: Int = Int(frame.height * 2)
        frame.origin = CGPoint(x: 0, y: 0)
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: true)
        descriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        
        let device = MTLCreateSystemDefaultDevice()!
        let options = [CIContextOption.workingColorSpace: NSColorSpace.sRGB]
        let context = CIContext(mtlDevice: device, options: options)
        let texture = device.makeTexture(descriptor: descriptor)!
        let renderer = CARenderer(mtlTexture: texture)
        renderer.layer = layer
        renderer.bounds.origin = CGPoint(x: 0, y: 0)
        renderer.bounds.size = CGSize(width: width, height: height)
        renderer.layer?.setAffineTransform(CGAffineTransform(scaleX: 2, y: 2))
        
        DispatchQueue.main.async {
            let time = CACurrentMediaTime()
            renderer.beginFrame(atTime: time, timeStamp: nil)
            renderer.addUpdate(renderer.bounds)
            renderer.render()
            renderer.endFrame()
            
            let ciImage = CIImage(mtlTexture: texture)!
            let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
            let size = CGSize(width: cgImage.width, height: cgImage.height)
            let nsImage = NSImage(cgImage: cgImage, size: size)
            completion(nsImage)
        }
    }
}
