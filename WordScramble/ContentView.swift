//
//  ContentView.swift
//  WordScramble
//
//  Created by Daniel Jesus Callisaya Hidalgo on 20/12/21.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    var score : Int {
        get {
           return usedWords.count
        }
    }
    var body: some View {
        NavigationView {
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                Section{
                    ForEach(usedWords, id: \.self){ word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                    
                }
                
             
            }
            .toolbar{
                ToolbarItemGroup(placement: .bottomBar) {
                    Text("Score: \(score)")
                        .font(.title3)
                    Spacer()
                    Button("New Word") {
                        startGame()
                    }
                }
            }
            .navigationTitle(rootWord)
                .onSubmit (addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
            }
          
        }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    func isRootWord(word: String) -> Bool {
        word == rootWord ? false : true
            
    }
    func hasMinimumLength(word: String) -> Bool {
        if word.count > 3  {
            return true
        }
        return false
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")

                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords = []
                // If we are here everything has worked, so we can exit
                return
            }
        }
        // If were are *here* then there was a problem – trigger a crash and report the error
           fatalError("Could not load start.txt from bundle.")
       }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard hasMinimumLength(word: answer) else {
            wordError(title: "Word is very short", message: "Please use more than 3 characters")
            return
        }
        guard isRootWord(word: answer) else{
            wordError(title: "Word is the rootword", message: "Please use other")
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    }
  




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
