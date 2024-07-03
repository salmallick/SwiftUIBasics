import SwiftUI

struct StreamView: View {
    @State private var availableStorage: Int64?
    @State private var isGenerating = false
    
    var body: some View {
        VStack {
            if let availableStorage = availableStorage {
                if availableStorage < 4_000_000_000 {
                    Text("You have \(ByteCountFormatter.string(fromByteCount: availableStorage, countStyle: .file)) of space available. 4 GB is needed")
                        .padding()
                } else {
                    Text("You have sufficient storage space.")
                        .padding()
                    
                    Button(action: {
                        isGenerating = true
                        // Add your generation logic here
                    }) {
                        Text("Generate")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isGenerating)
                    
                    if isGenerating {
                        ProgressView("Generating...")
                            .padding()
                    }
                }
            } else {
                ProgressView()
                    .padding()
            }
        }
        .onAppear {
            availableStorage = getAvailableStorage()
        }
    }
    
    func getAvailableStorage() -> Int64? {
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        do {
            let values = try documentDirectoryURL?.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let availableCapacity = values?.volumeAvailableCapacityForImportantUsage {
                return availableCapacity
            }
        } catch {
            print("Error getting available storage")
        }
        return nil
    }
}
