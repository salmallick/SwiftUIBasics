//
//  AIView.swift
//  FirstApp
//
//  Created by Salman on 4/20/24.
//


import Foundation
import SwiftUI
import llmfarm_core


public struct AIView: View {
    @State private var availableStorage: Int64?
    @State private var isDownloading = false
    let maxOutputLength = 256
    @State var totalOutput = 0
    @State var ai: AI?
    @State var params: ModelAndContextParams = .default
    
    init() {
        availableStorage = getAvailableStorage()
        setupLLMFarm()
    }
    @State private var modelName = "TinyLlama 1B"
    @State private var modelUrl = "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q8_0.gguf?download=true"
    @State private var filename = "tinyllama-1.1b-chat-v1.0.Q8_0.gguf"
    @State private var status = "download"

    
    
   public var body: some View {
        VStack {
            if isDownloading {
                ProgressView("Downloading AI Model...")
            } else if let availableStorage = availableStorage, availableStorage < 4_000_000_000 {
                Text("You have \(ByteCountFormatter.string(fromByteCount: availableStorage, countStyle: .file)) of space available. 4 GB is needed")
            } else {
                Button(action: {
                    isDownloading = true
                    runLLM(prompt: "State the meaning of life")
                }) {
                    Text("Download AI Model")
                }
            }
            DownloadButton(modelName: $modelName, modelUrl:  $modelUrl, filename:  $filename, status: $status)
            
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
    
   func setupLLMFarm() {
        params.promptFormat = .Custom
        params.custom_prompt_format = """
                SYSTEM: You are a helpful, respectful and honest assistant.
                USER: {prompt}
                ASSISTANT:
                """
        params.use_metal = true
        
        ai = AI(_modelPath: "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q6_K.gguf", _chatName: "chat")
       _ = try? ai?.loadModel(ModelInference.LLama_gguf, contextParams: params)
    }
    func mainCallback(_ str: String, _ time: Double) -> Bool {
        print("\(str)", terminator: "")
        totalOutput += str.count
        
        if totalOutput > maxOutputLength {
            return true
        }
        return false
    }
    func runLLM(prompt: String) {
        let output = try? ai?.model.predict(prompt, mainCallback)
    }
    
}

