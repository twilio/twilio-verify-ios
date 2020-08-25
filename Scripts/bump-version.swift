#!/usr/bin/swift

import Foundation

struct VersionNumber {
  var key: String
  var versionComponents: [String]

  var version: String {
    return versionComponents.joined(separator: Constants.Separator.dot)
  }
}

struct Constants {
  static let versionFileRelativePath = "TwilioVerify/Config/Version.xcconfig"
  static let missingArgumentsError = """
  Please pass a valid parameter according to the changes in this PR:
    - patch: This is a patch
    - minor: This is a minor change (non-breaking, backwards compatible, enhancement)
    - major: This is a major change (breaking changes)
  """
  struct Separator {
    static let dot = "."
    static let space = " "
    static let newLine = "\n"
  }
  struct Git {
    struct Actions {
      static let add = "add"
      static let commit = "commit"
      static let commitMessage = "-m"
    }
  }
  struct Keys {
    static let filePath = "{file_path}"
    static let message = "{message}"
  }
}

enum ChangeType: String {
  case patch
  case minor
  case major
}

func bumpVersion() {
  guard CommandLine.argc > 1, let changeType = ChangeType(rawValue: CommandLine.arguments[1]) else {
    print(Constants.missingArgumentsError)
    return
  }
  var versionNumber = currentVersionNumber()
  var version = versionNumber.versionComponents.map {Int($0)!}
  switch changeType {
    case .patch:
      version[2] += 1
    case .minor:
      version[1] += 1
      version[2] = 0
    case .major:
      version[0] += 1
      version[1] = 0
      version[2] = 0
  }
  versionNumber.versionComponents = version.map {String($0)}
  updateFile(withVersion: versionNumber)
  commitChanges(forChangeType: changeType)
}

func currentVersionNumber() -> VersionNumber {
  let versionFilePath = versionFilePathURL()
  do {
    let fileContents = try String(contentsOf: versionFilePath, encoding: .utf8)
    let marketingVersionComponents = fileContents.components(separatedBy: Constants.Separator.newLine)[0]
                                      .components(separatedBy: Constants.Separator.space)
    let versionKey = marketingVersionComponents[0]
    let currentVersion = marketingVersionComponents.last!
    let currentVersionComponents = currentVersion.components(separatedBy: Constants.Separator.dot)
    return VersionNumber(key: versionKey, versionComponents: currentVersionComponents)
  } catch {
    print(error.localizedDescription)
  }
  return VersionNumber(key: String(), versionComponents: [String()])
}

func updateFile(withVersion versionNumber: VersionNumber) {
  let versionFilePath = versionFilePathURL()
  let newVersion = "\(versionNumber.key) = \(versionNumber.version)"
  do {
    try newVersion.write(to: versionFilePath, atomically: true, encoding: .utf8)
  } catch {
    print(error.localizedDescription)
  }
}

func commitChanges(forChangeType type: ChangeType) {
  let commitMessage = "[Bump Version] - Bumped \(type.rawValue) version"
  shell(Constants.Git.Actions.add, 
        Constants.versionFileRelativePath)
  shell(Constants.Git.Actions.commit, 
        Constants.Git.Actions.commitMessage,
        commitMessage)
  shell("push", "origin", "savila/ACCSEC-18513")
}

func versionFilePathURL() -> URL {
  let currentPathURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
  return currentPathURL.appendingPathComponent(Constants.versionFileRelativePath)
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

bumpVersion()