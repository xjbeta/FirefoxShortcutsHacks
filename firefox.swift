#!/usr/bin/env swift

import Darwin
import Foundation

@discardableResult
func shell(_ command: String) -> Int32 {
    let task = Process()
    task.launchPath = "/bin/zsh"
    task.arguments = ["-c", command]
    task.launch()
    task.waitUntilExit()

    return task.terminationStatus
}

let firefoxPath = "/Applications/Firefox.app"
let omnijaPath = firefoxPath + "/Contents/Resources/browser/omni.ja"
let tmp = NSTemporaryDirectory() + "firefox.omni.ja"

func fileExists(_ path: String) -> Bool {
    return FileManager.default.fileExists(atPath: path)
}

func clearTmp() {
    try? FileManager.default.removeItem(atPath: tmp)
}

print("\(omnijaPath)")
if !fileExists(omnijaPath) {
    print("omni.ja not exists")
    exit(0)
}

print("\(tmp)")
clearTmp()



shell("unzip -q \(omnijaPath) -d \(tmp)")
//shell("unzip \(omnijaPath) -d \(tmp)")


let file1 = tmp + "/chrome/browser/content/browser/browser.xhtml"

print(file1)

if let content = FileManager.default.contents(atPath: file1),
   var string = String(data: content, encoding: .utf8) {

    string = string.replacingOccurrences(
        of: #"<key id="key_privatebrowsing" command="Tools:PrivateBrowsing" data-l10n-id="private-browsing-shortcut""#,
        with: #"<key id="key_privatebrowsing" command="Tools:PrivateBrowsing" data-l10n-id="window-new-shortcut""#)

    string = string.replacingOccurrences(
        of: #"<key id="key_undoCloseWindow" command="History:UndoCloseWindow" data-l10n-id="window-new-shortcut" modifiers="accel,shift"/>"#,
        with: #"<key id="key_undoCloseWindow" command="History:UndoCloseWindow"/>"#)

    do {
        try string.data(using: .utf8)?.write(to: .init(fileURLWithPath: file1))
    } catch let error {
        print("write new file content error \(error)")
        exit(0)
    }
} else {
    print("Can't load data from \(file1)")
    exit(0)
}


let file2 = tmp + "/localization/en-US/browser/browserSets.ftl"
print(file2)

if let content = FileManager.default.contents(atPath: file2),
   var string = String(data: content, encoding: .utf8) {
    string = string.replacingOccurrences(
        of: "private-browsing-shortcut =\n    .key = P\n\n",
        with: "")
    do {
        try string.data(using: .utf8)?.write(to: .init(fileURLWithPath: file2))
    } catch let error {
        print("write new file content error \(error)")
        exit(0)
    }
    
} else {
    print("Can't load data from \(file2)")
    exit(0)
}

let bak = omnijaPath + ".bak"
let new = omnijaPath + ".new"

shell("mv \(omnijaPath) \(bak)")
print("backup omni.ja to \(bak)")

shell("cd \(tmp); zip -qr9XD \(new) *")
print("zip omni.ja to \(new)")

clearTmp()
print("clear tmp files.")


print("1. Open Firefox.app")
print("2. Click 'Quit Firefox'")

let path = NSString(string: omnijaPath).deletingLastPathComponent

print("3. Go to this path: \(path)")
print("4. Rename 'omni.ja.new' to 'omni.ja'")