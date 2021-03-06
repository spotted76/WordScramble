//
//  ContentView.swift
//  WordScramble
//
//  Created by Peter Fischer on 3/18/22.
//

import SwiftUI


struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var numGames : Int {
        usedWords.count
    }
    
    var countTotal : Int {
        var total = 0
        for curr in usedWords {
            total += curr.count
        }
        
        return total
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                                .foregroundColor(
                                    word.count >= 5 ? Color.blue : .primary)
                            Text(word)
                        }
                    }
                }

            }
            .toolbar {
                ToolbarItem(placement: .status) {
                    Text("Games : \(numGames) / Count: \(countTotal)")
                        .foregroundColor(Color.blue)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset", role: .destructive, action: startGame)
                }
                
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("Ok", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard meetsMinDuration(word: answer) else {
            wordError(title: "Word too short", message: "Answer must be greater than 3 characters")
            return
        }
        
        guard isLame(word: answer) else {
            wordError(title: "Answer is lame", message: "Be unique, you can't type the same exact word")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from \(rootWord)")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word is not recognized", message: "You can't just make them up!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt")
        {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords = [String]()
                return
            }
        }
        
        fatalError("Could not load start.txt from the bundle")
    }
    
    func meetsMinDuration(word: String) -> Bool {
        word.count <= 3 ? false : true
    }
    
    func isLame(word: String) -> Bool {
        word == rootWord ? false : true
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            }
            else {
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
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
