//
//  ContentView.swift
//  Concentrator
//
//  Created by Johannes Loeffler on 2/24/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background Image (Non-Interactive)
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(0)  // Send background to the back

                // Foreground Content
                VStack {
                    Text("The Concentrator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .shadow(color: .white, radius: 8) // Better contrast
                        .padding()

                    // Navigation Buttons
                    VStack(spacing: 15) {  // Keep buttons nicely spaced
                        NavigationLink(destination: ConversionView()) {
                            Text("Convert Concentration")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.indigo.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }

                        NavigationLink(destination: DilutionView()) {
                            Text("Calculate Dilution")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }

                        NavigationLink(destination: ComplexingView()) {
                            Text("Complexing")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.teal.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal) // Keep button width consistent
                }
                .zIndex(1)  // Ensure the buttons stay clickable
            }
        }
    }
}



// Helper Functions
func molToMg(molConc: Double, molWeight: Double) -> Double {
    if molWeight <= 0 {
        fatalError("Molecular weight must be a positive value.")
    }
    return molConc * molWeight
}

func mgToMol(mgConc: Double, molWeight: Double) -> Double {
    if molWeight <= 0 {
        fatalError("Molecular weight must be a positive value.")
    }
    return mgConc / molWeight
}

func convertConcentration(concentration: Double, fromUnit: String, toUnit: String, molWeight: Double) -> Double {
    var baseConcentration = concentration

    // Convert to base unit (mol/L)
    switch fromUnit {
    case "mg/mL":
        baseConcentration = mgToMol(mgConc: concentration, molWeight: molWeight)
    case "mM":
        baseConcentration /= 1e3
    case "µM":
        baseConcentration /= 1e6
    case "nM":
        baseConcentration /= 1e9
    default:
        break
    }

    // Convert from base unit to target unit
    switch toUnit {
    case "mg/mL":
        baseConcentration = molToMg(molConc: baseConcentration, molWeight: molWeight)
    case "mM":
        baseConcentration *= 1e3
    case "µM":
        baseConcentration *= 1e6
    case "nM":
        baseConcentration *= 1e9
    default:
        break
    }

    return baseConcentration
}


struct ConversionView: View {
    @State private var fromUnit = "mg/mL"
    @State private var toUnit = "mol/L"
    @State private var molWeight: String = ""
    @State private var concentration: String = ""
    @State private var result: String = ""

    var body: some View {
        VStack {
            Text("Unit Conversions").font(.largeTitle).foregroundColor(.indigo)

            HStack {
                Text("From Unit:")
                Picker("From Unit", selection: $fromUnit) {
                    Text("mol/L").tag("mol/L")
                    Text("mM").tag("mM")
                    Text("µM").tag("µM")
                    Text("nM").tag("nM")
                    Text("mg/mL").tag("mg/mL")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
            }

            HStack {
                Text("To Unit:")
                Picker("To Unit", selection: $toUnit) {
                    Text("mol/L").tag("mol/L")
                    Text("mM").tag("mM")
                    Text("µM").tag("µM")
                    Text("nM").tag("nM")
                    Text("mg/mL").tag("mg/mL")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
            }

            if fromUnit == "mg/mL" || toUnit == "mg/mL" {
                HStack {
                    Text("Molecular Weight (g/mol):")
                    TextField("Molecular Weight", text: $molWeight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
            }

            HStack {
                Text("Concentration:")
                TextField("Concentration", text: $concentration)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            Button(action: {
                self.convert()
            }) {
                Text("Convert")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            // Display formatted result
            Text(result)
                .font(.title2)
                .foregroundColor(.indigo)
                .padding()

            Spacer()
        }
        .padding()
    }

    // Convert button action
    func convert() {
        // Ensure concentration is valid
        guard let concentrationValue = Double(concentration) else {
            result = "Please enter a valid concentration."
            return
        }

        // Check if molecular weight is required
        var molWeightValue: Double = 1.0
        if fromUnit == "mg/mL" || toUnit == "mg/mL" {
            guard let mw = Double(molWeight), mw > 0 else {
                result = "Please enter a valid molecular weight."
                return
            }
            molWeightValue = mw
        }

        // Perform conversion
        let convertedValue = convertConcentration(concentration: concentrationValue, fromUnit: fromUnit, toUnit: toUnit, molWeight: molWeightValue)

        // Format output with 2 decimal places (scientific notation for extreme values)
        let formattedInput = formatNumber(concentrationValue)
        let formattedOutput = formatNumber(convertedValue)

        // Display result in full equation format
        result = "\(formattedInput) \(fromUnit) = \(formattedOutput) \(toUnit)"
    }

    // Format number with 2 decimal places or scientific notation for very large/small values
    func formatNumber(_ value: Double) -> String {
        if abs(value) >= 1e6 || abs(value) < 1e-3 && value != 0 {
            return String(format: "%.2e", value)  // Use scientific notation
        } else {
            return String(format: "%.2f", value)  // Use fixed decimal format
        }
    }
}

struct DilutionView: View {
    @State private var stockConcentration: String = ""
    @State private var finalConcentration: String = ""
    @State private var finalVolume: String = ""

    @State private var stockUnit = "mol/L"
    @State private var finalUnit = "mol/L"
    @State private var volumeUnit = "mL"
    @State private var molWeight: String = ""

    @State private var result: String = ""

    var body: some View {
        VStack {
            Text("Calculate Dilution").font(.largeTitle).foregroundColor(.blue)

            HStack {
                Text("Stock Concentration:")
                TextField("Stock Concentration", text: $stockConcentration)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            HStack {
                Text("Stock Unit:")
                Picker("Stock Unit", selection: $stockUnit) {
                    Text("mol/L").tag("mol/L")
                    Text("mM").tag("mM")
                    Text("µM").tag("µM")
                    Text("nM").tag("nM")
                    Text("mg/mL").tag("mg/mL")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
            }

            HStack {
                Text("Final Concentration:")
                TextField("Final Concentration", text: $finalConcentration)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            HStack {
                Text("Final Unit:")
                Picker("Final Unit", selection: $finalUnit) {
                    Text("mol/L").tag("mol/L")
                    Text("mM").tag("mM")
                    Text("µM").tag("µM")
                    Text("nM").tag("nM")
                    Text("mg/mL").tag("mg/mL")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
            }

            HStack {
                Text("Final Volume:")
                TextField("Final Volume", text: $finalVolume)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            HStack {
                Text("Volume Unit:")
                Picker("Volume Unit", selection: $volumeUnit) {
                    Text("mL").tag("mL")
                    Text("µL").tag("µL")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
            }

            if stockUnit == "mg/mL" || finalUnit == "mg/mL" {
                HStack {
                    Text("Molecular Weight (g/mol):")
                    TextField("Molecular Weight", text: $molWeight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
            }

            Button(action: {
                self.calculateDilution()
            }) {
                Text("Calculate Dilution")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            // Display formatted result
            Text(result)
                .font(.title2)
                .foregroundColor(.blue)
                .padding()

            Spacer()
        }
        .padding()
    }

    func calculateDilution() {
        // Ensure all inputs are valid numbers
        guard let stockConc = Double(stockConcentration),
              let finalConc = Double(finalConcentration),
              let finalVol = Double(finalVolume),
              stockConc > 0, finalConc > 0, finalVol > 0 else {
            result = "Please enter valid positive values for all fields."
            return
        }

        // Handle mg/mL cases requiring molecular weight
        var molWeightValue: Double = 1.0
        if stockUnit == "mg/mL" || finalUnit == "mg/mL" {
            guard let mw = Double(molWeight), mw > 0 else {
                result = "Please enter a valid molecular weight."
                return
            }
            molWeightValue = mw
        }

        // Convert all concentration units to mol/L
        let stockConcMol = convertToMol(stockConc, from: stockUnit, molWeight: molWeightValue)
        let finalConcMol = convertToMol(finalConc, from: finalUnit, molWeight: molWeightValue)

        // Convert µL to mL if necessary
        var finalVolML = finalVol
        if volumeUnit == "µL" {
            finalVolML /= 1000.0
        }

        // Perform dilution calculation
        let stockVol = (finalConcMol * finalVolML) / stockConcMol
        let diluentVol = finalVolML - stockVol

        // Convert back to µL if necessary
        let stockVolFormatted = volumeUnit == "µL" ? stockVol * 1000.0 : stockVol
        let diluentVolFormatted = volumeUnit == "µL" ? diluentVol * 1000.0 : diluentVol

        // Format output
        result = String(format: "Stock: %.2f %@, Diluent: %.2f %@", stockVolFormatted, volumeUnit, diluentVolFormatted, volumeUnit)
    }

    func convertToMol(_ concentration: Double, from unit: String, molWeight: Double) -> Double {
        switch unit {
        case "mg/mL":
            return mgToMol(mgConc: concentration, molWeight: molWeight)
        case "mM":
            return concentration / 1e3
        case "µM":
            return concentration / 1e6
        case "nM":
            return concentration / 1e9
        default:
            return concentration
        }
    }
}



struct ComplexingView: View {
    @State private var compounds: [Compound] = [Compound()]  // Start with 1 compound
    @State private var finalConc: String = ""
    @State private var finalVolume: String = ""
    @State private var finalConcUnit = "mol/L"
    @State private var volumeUnit = "mL"
    @State private var result: String = ""
    @State private var finalMass: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Complexing")
                    .font(.largeTitle).foregroundColor(.teal)
                    .padding()
                
                // Dynamic Input Fields for Each Compound
                ForEach(compounds.indices, id: \.self) { index in
                    VStack {
                        HStack {
                            Text("Compound \(index + 1):")
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: { removeCompound(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        HStack {
                            Text("Concentration:")
                            TextField("Stock Concentration", text: $compounds[index].conc)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                        }
                        
                        HStack {
                            Text("Unit:")
                            Picker("Unit", selection: $compounds[index].unit) {
                                ForEach(["mol/L", "mM", "µM", "nM", "mg/mL"], id: \.self) { unit in
                                    Text(unit).tag(unit)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 150)
                        }
                        
                        if compounds[index].unit == "mg/mL" {
                            HStack {
                                Text("Molecular Weight (g/mol):")
                                TextField("MW", text: $compounds[index].molWeight)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                            }
                        }
                        
                        HStack {
                            Text("Ratio:")
                            Picker("Ratio", selection: $compounds[index].ratio) {
                                ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 150)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.teal.opacity(0.2)))
                }
                
                // Add Compound Button
                Button(action: addCompound) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Compound")
                    }
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.teal.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                
                // Final Concentration & Volume
                HStack {
                    Text("Final Concentration:")
                    TextField("Target Concentration", text: $finalConc)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                
                HStack {
                    Text("Unit:")
                    Picker("Unit", selection: $finalConcUnit) {
                        ForEach(["mol/L", "mM", "µM", "nM", "mg/mL"], id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 150)
                }
                
                if finalConcUnit == "mg/mL" {
                    HStack {
                        Text("Final Mass:")
                        TextField("Mass", text: $finalMass)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                }
                
                HStack {
                    Text("Final Volume:")
                    TextField("Target Volume", text: $finalVolume)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                
                HStack {
                    Text("Volume Unit:")
                    Picker("Unit", selection: $volumeUnit) {
                        ForEach(["mL", "µL"], id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 150)
                }
                
                // Calculate Button
                Button(action: calculateMultiComplexing) {
                    Text("Calculate")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                // Display Results
                VStack {
                    Text(result)
                        .font(.title2)
                        .foregroundColor(.teal)
                        .multilineTextAlignment(.center)
                        .padding()
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom)
                
                Spacer()
            }
            .padding()
        }
    }
    
    func addCompound() {
        compounds.append(Compound())
    }
    
    func removeCompound(at index: Int) {
        if compounds.count > 1 {
            compounds.remove(at: index)
        }
    }
    
    func calculateMultiComplexing() {
        guard let cf = Double(finalConc), cf > 0,
              let vf = Double(finalVolume), vf > 0 else {
            result = "Please enter valid positive values for final concentration and volume."
            return
        }

        var totalVol = vf
        let isMicroLiter = volumeUnit == "µL"
        if isMicroLiter { totalVol /= 1000.0 } // Convert to mL if needed

        var totalRatio = 0
        for compound in compounds {
            totalRatio += compound.ratio
        }

        var volumeDict: [UUID: Double] = [:]
        var totalCalculatedVolume: Double = 0

        for compound in compounds {
            guard let c = Double(compound.conc), c > 0 else {
                result = "Please enter valid concentrations for all compounds."
                return
            }
            let mw = compound.unit == "mg/mL" ? Double(compound.molWeight) ?? 1.0 : 1.0
            let cMol = convertToMol(c, from: compound.unit, molWeight: mw)
            let cfMol = convertToMol(cf, from: finalConcUnit, molWeight: 1.0)
            
            // Calculate the final concentration contribution of this compound
            let finalC = (Double(compound.ratio) / Double(totalRatio)) * cfMol
            // Calculate the volume needed from the stock solution
            let volume = (finalC * totalVol) / cMol
            volumeDict[compound.id, default: 0] += isMicroLiter ? volume * 1000.0 : volume
            totalCalculatedVolume += isMicroLiter ? volume * 1000.0 : volume
        }

        // Calculate buffer volume to complete the total volume
        let bufferVolume = max(0, vf - totalCalculatedVolume)

        result = compounds.enumerated().map { (index, compound) in
            "Compound \(index + 1): \(String(format: "%.2f", volumeDict[compound.id] ?? 0)) \(volumeUnit)"
        }.joined(separator: "\n") + "\nBuffer: \(String(format: "%.2f", bufferVolume)) \(volumeUnit)"
    }

    func convertToMol(_ concentration: Double, from unit: String, molWeight: Double) -> Double {
        switch unit {
        case "mg/mL":
            return mgToMol(mgConc: concentration, molWeight: molWeight)
        case "mM":
            return concentration / 1e3
        case "µM":
            return concentration / 1e6
        case "nM":
            return concentration / 1e9
        default:
            return concentration
        }
    }

    func mgToMol(mgConc: Double, molWeight: Double) -> Double {
        return mgConc / molWeight
    }
}
struct Compound: Identifiable {
    let id = UUID()
    var conc: String = ""
    var unit: String = "mol/L"
    var molWeight: String = ""
    var ratio: Int = 1
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
