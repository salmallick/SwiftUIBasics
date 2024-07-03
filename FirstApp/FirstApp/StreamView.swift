import SwiftUI
import WhisperKit
import Network

struct StreamView: View {
    @State private var availableStorage: Int64?
    @State private var isGenerating = false
    @State private var isConnected = false
    @State private var localModelPath: String = ""
    @State private var availableModels: [String] = []
    @State private var localModels: [String] = []
    @State private var disabledModels: [String] = WhisperKit.recommendedModels().disabled
    @State var modelStorage: String = "huggingface/models/argmaxinc/whisperkit-coreml"
    
    @AppStorage("selectedModel") private var selectedModel: String = WhisperKit.recommendedModels().default
    @AppStorage("repoName") private var repoName: String = "argmaxinc/whisperkit-coreml"

    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkMonitor")
    
    var body: some View {
        VStack {
            if let availableStorage = availableStorage {
                if availableStorage < 4_000_000_000 {
                    Text("You have \(ByteCountFormatter.string(fromByteCount: availableStorage, countStyle: .file)) of space available. 4 GB is needed")
                        .padding()
                } else if !isConnected {
                    Text("No internet connection. Please connect to WiFi or cellular data.")
                        .padding()
                    
                } else {
                    Text("You have sufficient storage space.")
                        .padding()
                    
                    Button(action: {
                        fetchModels()
                        
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
            startNetworkMonitoring()
        }
        .onDisappear {
            stopNetworkMonitoring()
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
    func startNetworkMonitoring() {
            monitor.pathUpdateHandler = { path in
                DispatchQueue.main.async {
                    self.isConnected = path.status == .satisfied
                }
            }
            monitor.start(queue: queue)
        }
        
        func stopNetworkMonitoring() {
            monitor.cancel()
        }
    func fetchModels() {
          availableModels = [selectedModel]

          // First check what's already downloaded
          if let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
              let modelPath = documents.appendingPathComponent(modelStorage).path

              // Check if the directory exists
              if FileManager.default.fileExists(atPath: modelPath) {
                  localModelPath = modelPath
                  do {
                      let downloadedModels = try FileManager.default.contentsOfDirectory(atPath: modelPath)
                      for model in downloadedModels where !localModels.contains(model) {
                          localModels.append(model)
                      }
                  } catch {
                      print("Error enumerating files at \(modelPath): \(error.localizedDescription)")
                  }
              }
          }

          localModels = WhisperKit.formatModelFiles(localModels)
          for model in localModels {
              if !availableModels.contains(model),
                 !disabledModels.contains(model)
              {
                  availableModels.append(model)
              }
          }

          print("Found locally: \(localModels)")
          print("Previously selected model: \(selectedModel)")

          Task {
              let remoteModels = try await WhisperKit.fetchAvailableModels(from: repoName)
              for model in remoteModels {
                  if !availableModels.contains(model),
                     !disabledModels.contains(model)
                  {
                      availableModels.append(model)
                  }
                  if (model == "openai_whisper-base"){
//                      loadModel(model)
                  }
              }
          }
      }
    
//    func loadModel(_ model: String, redownload: Bool = false) {
//            print("Selected Model: \(UserDefaults.standard.string(forKey: "selectedModel") ?? "nil")")
//            print("""
//                Computing Options:
//                - Mel Spectrogram:  \(getComputeOptions().melCompute.description)
//                - Audio Encoder:    \(getComputeOptions().audioEncoderCompute.description)
//                - Text Decoder:     \(getComputeOptions().textDecoderCompute.description)
//                - Prefill Data:     \(getComputeOptions().prefillCompute.description)
//            """)
//
//            whisperKit = nil
//            Task {
//                whisperKit = try await WhisperKit(
//                    computeOptions: getComputeOptions(),
//                    verbose: true,
//                    logLevel: .debug,
//                    prewarm: false,
//                    load: false,
//                    download: false
//                )
//                guard let whisperKit = whisperKit else {
//                    return
//                }
//
//                var folder: URL?
//
//                // Check if the model is available locally
//                if localModels.contains(model) && !redownload {
//                    // Get local model folder URL from localModels
//                    // TODO: Make this configurable in the UI
//                    folder = URL(fileURLWithPath: localModelPath).appendingPathComponent(model)
//                } else {
//                    // Download the model
//                    folder = try await WhisperKit.download(variant: model, from: repoName, progressCallback: { progress in
//                        DispatchQueue.main.async {
//                            loadingProgressValue = Float(progress.fractionCompleted) * specializationProgressRatio
//                            modelState = .downloading
//                        }
//                    })
//                }
//
//                await MainActor.run {
//                    loadingProgressValue = specializationProgressRatio
//                    modelState = .downloaded
//                }
//
//                if let modelFolder = folder {
//                    whisperKit.modelFolder = modelFolder
//
//                    await MainActor.run {
//                        // Set the loading progress to 90% of the way after prewarm
//                        loadingProgressValue = specializationProgressRatio
//                        modelState = .prewarming
//                    }
//
//                    let progressBarTask = Task {
//                        await updateProgressBar(targetProgress: 0.9, maxTime: 240)
//                    }
//
//                    // Prewarm models
//                    do {
//                        try await whisperKit.prewarmModels()
//                        progressBarTask.cancel()
//                    } catch {
//                        print("Error prewarming models, retrying: \(error.localizedDescription)")
//                        progressBarTask.cancel()
//                        if !redownload {
//                            loadModel(model, redownload: true)
//                            return
//                        } else {
//                            // Redownloading failed, error out
//                            modelState = .unloaded
//                            return
//                        }
//                    }
//
//                    await MainActor.run {
//                        // Set the loading progress to 90% of the way after prewarm
//                        loadingProgressValue = specializationProgressRatio + 0.9 * (1 - specializationProgressRatio)
//                        modelState = .loading
//                    }
//
//                    try await whisperKit.loadModels()
//
//                    await MainActor.run {
//                        if !localModels.contains(model) {
//                            localModels.append(model)
//                        }
//
//                        availableLanguages = Constants.languages.map { $0.key }.sorted()
//                        loadingProgressValue = 1.0
//                        modelState = whisperKit.modelState
//                    }
//                    
//                }
//            }
//        }
    }

