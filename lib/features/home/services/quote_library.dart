import 'dart:math';
import '../models/motivational_quote.dart';

class QuoteLibrary {
  static const List<MotivationalQuote> quotes = [
    MotivationalQuote(
      quote: "No act of kindness, no matter how small, is ever wasted.",
      author: "Aesop",
      topic: "Kindness",
    ),
    MotivationalQuote(
      quote: "Kind words can be short and easy to speak, but their echoes are truly endless.",
      author: "Mother Teresa",
      topic: "Compassion",
    ),
    MotivationalQuote(
      quote: "Constant kindness can accomplish much. As the sun makes ice melt, kindness causes misunderstanding, mistrust, and hostility to evaporate.",
      author: "Albert Schweitzer",
      topic: "Growth",
    ),
    MotivationalQuote(
      quote: "A single gentle word can transform someone's entire day.",
      author: "Dalai Lama",
      topic: "Empathy",
    ),
    MotivationalQuote(
      quote: "Try to be a rainbow in someone's cloud.",
      author: "Maya Angelou",
      topic: "Hope",
    ),
    MotivationalQuote(
      quote: "We make a living by what we get, but we make a life by what we give.",
      author: "Winston Churchill",
      topic: "Generosity",
    ),
    MotivationalQuote(
      quote: "Tenderness and kindness are not signs of weakness and despair, but manifestations of strength and resolution.",
      author: "Kahlil Gibran",
      topic: "Strength",
    ),
    MotivationalQuote(
      quote: "Wherever there is a human being, there is an opportunity for a kindness.",
      author: "Seneca",
      topic: "Community",
    ),
    MotivationalQuote(
      quote: "Kindness is the language which the deaf can hear and the blind can see.",
      author: "Mark Twain",
      topic: "Humanity",
    ),
    MotivationalQuote(
      quote: "You cannot do a kindness too soon, for you never know how soon it will be too late.",
      author: "Ralph Waldo Emerson",
      topic: "Presence",
    ),
    MotivationalQuote(
      quote: "What wisdom can you find that is greater than kindness?",
      author: "Jean-Jacques Rousseau",
      topic: "Wisdom",
    ),
    MotivationalQuote(
      quote: "In a world where you can be anything, be kind.",
      author: "Jennifer Dukes Lee",
      topic: "Purpose",
    ),
    MotivationalQuote(
      quote: "Peace cannot be kept by force; it can only be achieved by understanding.",
      author: "Albert Einstein",
      topic: "Peace",
    ),
    MotivationalQuote(
      quote: "To love oneself is the beginning of a lifelong romance.",
      author: "Oscar Wilde",
      topic: "Self-Care",
    ),
    MotivationalQuote(
      quote: "The smallest act of caring has the potential to turn a life around.",
      author: "Mary Anne Radmacher",
      topic: "Caring",
    ),
    MotivationalQuote(
      quote: "Give what you have. To someone, it may be better than you dare to think.",
      author: "Henry Wadsworth Longfellow",
      topic: "Generosity",
    ),
  ];

  /// Returns a random quote, optionally avoiding the current quote
  static MotivationalQuote getRandomQuote([MotivationalQuote? current]) {
    final random = Random();
    if (quotes.length <= 1) return quotes.first;
    MotivationalQuote selected;
    do {
      selected = quotes[random.nextInt(quotes.length)];
    } while (current != null && selected.quote == current.quote);
    return selected;
  }
}
