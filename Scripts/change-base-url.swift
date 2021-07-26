#!/usr/bin/swift

import Foundation

struct Constants {
  static let configFileRelativePath = "../TwilioVerifySDK/TwilioVerify/Sources/TwilioVerifyConfig.swift"
  static let missingArgumentsError = """
  Expected base URL argument not set correctly
  """
  static let baseURLKey = "baseURL"
  
  struct Separator {
    static let equal: Character = "="
    static let newLine = "\n"
  }
}

func changeBaseURL() {
  guard CommandLine.argc > 1  else {
    print(Constants.missingArgumentsError)
    return
  }
  let baseURL = CommandLine.arguments[1]
  print("Changing base URL to \(baseURL)")
  updateConfigFile(withBaseURL: baseURL)
}

func updateConfigFile(withBaseURL url: String) {
  let configFilePath = configFilePathURL()
  do {
    var fileContents = try String(contentsOf: configFilePath, encoding: .utf8)
    let baseURLComponents: [String] = fileContents.components(separatedBy: Constants.Separator.newLine).map {
      if $0.contains(Constants.baseURLKey) {
        let currentBaseURL = $0.split(separator: Constants.Separator.equal)[1].trimmingCharacters(in: .whitespacesAndNewlines)
        return $0.replacingOccurrences(of: currentBaseURL, with: "\"\(url)\"")
      } else {
        return $0
      }
    }
    fileContents = baseURLComponents.joined(separator: Constants.Separator.newLine)
    try fileContents.write(to: configFilePath, atomically: true, encoding: .utf8)
  } catch {
    print(error.localizedDescription)
  }
}

func configFilePathURL() -> URL {
  let currentPathURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
  return currentPathURL.appendingPathComponent(Constants.configFileRelativePath)
}

@discardableResult
func shell(_ args: String...) -> Int32 {
  let task = Process()
  task.launchPath = "/Applications/Xcode.app/Contents/Developer/usr/libexec/git-core/git"
  task.arguments = args
  task.launch()
  task.waitUntilExit()
  return task.terminationStatus
}

changeBaseURL()
