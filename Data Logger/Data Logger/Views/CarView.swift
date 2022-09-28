//
//  CarView.swift
//  Data Logger
//
//  Created by Adam Kopec on 13/09/2022.
//

import SwiftUI

struct CarView: View {
    @StateObject var dataLogger = (UIApplication.shared.delegate as! AppDelegate).dataLogger
    var body: some View {
        ScrollView {
            VStack {
                GroupBox {
                    VStack(alignment: .leading) {
                        HStack {
                            Label("There are no issues with your car", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Spacer()
                        }
                    }
                } label: {
                    Label("Car", systemImage: "car")
                        .foregroundColor(.blue)
                        .padding(.bottom, 5)
                }
                Spacer().padding(.vertical, 5)
                GroupBox {
                    if !dataLogger.isConnected {
                        HStack {
                            Label("Disconnected", systemImage: "moon.zzz.fill")
                                .foregroundColor(.secondary)
                                .font(Font.body.bold())
                            Spacer()
                        }
                    } else {
                        HStack {
                            Text("Battery Level")
                                .bold()
                            Spacer()
                            Text("\(dataLogger.batteryLevel)%")
                                .font(.callout)
                            batteryImage(basedOn: dataLogger.batteryLevel, isCharging: dataLogger.isCharging)
                                .symbolRenderingMode(.multicolor)
                                .font(.title2)
                        }
                        Spacer()
                        HStack {
                            Text("Serial Number")
                                .bold()
                            Spacer()
                            Text(dataLogger.serialNumber)
                                .font(.body.monospaced())
                                .foregroundColor(.secondary)
                        }
                    }
                } label: {
                    Label("Data Logger", systemImage: "memorychip")
                        .foregroundColor(.teal)
                        .padding(.bottom, 5)
                }
                Spacer().padding(.vertical, 5)
                // Wow, it's even working with UINavigationController as parent 😊
                NavigationLink("Next View", destination: CarView())
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .hidden()
            }
            .padding()
        }
    }
    
    func batteryImage(basedOn level: Int, isCharging: Bool = false) -> Image {
        if isCharging {
            return Image(systemName: "battery.100.bolt")
        }
        if (88...100).contains(level) {
            return Image(systemName: "battery.100")
        } else if (66...87).contains(level) {
            return Image(systemName: "battery.75")
        } else if (35...65).contains(level) {
            return Image(systemName: "battery.50")
        } else if (1...35).contains(level) {
            return Image(systemName: "battery.25")
        } else {
            return Image(systemName: "battery.0")
        }
    }
}

struct CarView_Previews: PreviewProvider {
    static var previews: some View {
        CarView()
    }
}

class CarHostingController: UIHostingController<CarView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: CarView())
    }
}
