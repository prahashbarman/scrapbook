//
//  CircularSlider.swift
//  TestCollapsibleStacks
//
//  Created by Himangshu Barman on 23/01/23.
//

import SwiftUI

protocol SliderValueDelegate {
    func valueChanged(value: Int)
}

struct CircularSliderView: View {
    var delegate: SliderValueDelegate? = nil
    let debouncer: Debouncer = Debouncer()
    @State var sliderValue: CGFloat = 0.0
    @State var angleValue: CGFloat = 0.0
    let circularSlider = SliderConfig(radius: 100.0, minimumValue: 0.0, maximumValue: 950000)
    var body: some View {
        ZStack {
            
            //Filled circle
            Circle()
                .stroke(Color.brown.opacity(0.3), lineWidth: 10)
                .frame(width: circularSlider.radius * 2, height: circularSlider.radius * 2)
            
            //Unfilled circle
            Circle()
                .trim(from: 0.0, to: sliderValue/circularSlider.maximumValue)
                .stroke(Color.brown, lineWidth: 10)
                .frame(width: circularSlider.radius * 2, height: circularSlider.radius * 2)
                .rotationEffect(Angle.degrees(-90))
            
            //Slider Ball Image
            Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.brown)
                .background(Color.cyan)
                .frame(width: 30.0, height: 30.0)
                .clipShape(Circle())
                .offset(y: -circularSlider.radius)
                .rotationEffect(min(Angle.degrees(Double(angleValue)), Angle.degrees(360)))
                .gesture(DragGesture(minimumDistance: 0.0)
                .onChanged({ value in
                    change(location: value.location)
                }))

            Text("Credit amount")
                .font(.custom("Avenir", fixedSize: 12))
                .fontWeight(.medium)
                .offset(y: -18)
                .foregroundColor(.black)
            Text("₹ \(Int(sliderValue/100) * 100)")
                .font(.custom("Avenir", fixedSize: 16))
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("+1.04% monthly")
                .font(.custom("Avenir", fixedSize: 12))
                .offset(y: 22)
                .fontWeight(.medium)
                .foregroundColor(.green)
        }
    }
    
    private func change(location: CGPoint) {
        let vector = CGVector(dx: location.x, dy: location.y)
        let radAngle = atan2(vector.dy - 25.0, vector.dx - 25.0) + .pi/2.0
        let angle = radAngle < 0.0 ? radAngle + 2.0 * .pi : radAngle
        var value = angle / (2.0 * .pi) * circularSlider.maximumValue
        
        while value > circularSlider.maximumValue {
            value -= circularSlider.maximumValue
        }
        
        if value >= circularSlider.minimumValue && value <= circularSlider.maximumValue {
            sliderValue = value
            angleValue = angle * 180 / .pi
            debouncer.notifyVC(value: Int(sliderValue/100) * 100, delegate: delegate)
        }
    }
}

struct SliderConfig {
    let radius: CGFloat
    let minimumValue: CGFloat
    let maximumValue: CGFloat
}

//Implements Debounce technique
class Debouncer {
    var value : Int = 0
    var workItem : DispatchWorkItem?
    func notifyVC(value: Int, delegate: SliderValueDelegate?) {
        workItem?.cancel()
        let valueUpdateWorkItem = DispatchWorkItem {
            delegate?.valueChanged(value: value)
        }
        workItem = valueUpdateWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem!)
    }
}
