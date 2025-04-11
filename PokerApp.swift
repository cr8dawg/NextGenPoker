// PokerApp.swift
import SwiftUI

@main
struct PokerApp: App {
    var body: some Scene {
        WindowGroup {
            PokerGameView()
        }
    }
}

// Card.swift
import Foundation

enum Suit: String, CaseIterable {
    case hearts = "♥️", diamonds = "♦️", clubs = "♣️", spades = "♠️"
}

enum Rank: String, CaseIterable {
    case two = "2", three = "3", four = "4", five = "5", six = "6"
    case seven = "7", eight = "8", nine = "9", ten = "10"
    case jack = "J", queen = "Q", king = "K", ace = "A"
}

struct Card: Identifiable, Equatable {
    let id = UUID()
    let suit: Suit
    let rank: Rank

    var display: String {
        "\(rank.rawValue)\(suit.rawValue)"
    }
}

// PokerGameViewModel.swift
import Foundation

class PokerGameViewModel: ObservableObject {
    @Published var playerCards: [Card] = []
    @Published var opponentCards: [Card] = []
    @Published var communityCards: [Card] = []
    @Published var stage: Int = 0

    private var deck: [Card] = []

    init() {
        startNewHand()
    }

    func startNewHand() {
        deck = Suit.allCases.flatMap { suit in
            Rank.allCases.map { rank in
                Card(suit: suit, rank: rank)
            }
        }.shuffled()

        playerCards = drawCards(count: 2)
        opponentCards = drawCards(count: 2)
        communityCards = []
        stage = 0
    }

    func advanceStage() {
        switch stage {
        case 0:
            communityCards.append(contentsOf: drawCards(count: 3)) // Flop
        case 1:
            communityCards.append(contentsOf: drawCards(count: 1)) // Turn
        case 2:
            communityCards.append(contentsOf: drawCards(count: 1)) // River
        default:
            break
        }
        stage += 1
    }

    private func drawCards(count: Int) -> [Card] {
        let drawn = Array(deck.prefix(count))
        deck.removeFirst(count)
        return drawn
    }
}

// PokerGameView.swift
import SwiftUI

struct PokerGameView: View {
    @StateObject private var viewModel = PokerGameViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Texas Hold'em Poker").font(.largeTitle)

            VStack {
                Text("Player's Hand")
                HStack {
                    ForEach(viewModel.playerCards) { card in
                        CardView(card: card)
                    }
                }
            }

            VStack {
                Text("Community Cards")
                HStack {
                    ForEach(viewModel.communityCards) { card in
                        CardView(card: card)
                    }
                }
            }

            VStack {
                Text("Opponent's Hand")
                HStack {
                    ForEach(viewModel.opponentCards) { card in
                        CardView(card: card)
                    }
                }
            }

            HStack(spacing: 20) {
                Button("New Hand") {
                    viewModel.startNewHand()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Next Stage") {
                    viewModel.advanceStage()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(viewModel.stage >= 3)
            }
        }
        .padding()
    }
}

struct CardView: View {
    let card: Card

    var body: some View {
        Text(card.display)
            .font(.system(size: 32))
            .frame(width: 60, height: 90)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}
