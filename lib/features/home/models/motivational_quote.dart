class MotivationalQuote {
  const MotivationalQuote({
    required this.quote,
    required this.author,
    required this.topic,
  });

  final String quote;
  final String author;
  final String topic;

  factory MotivationalQuote.fromJson(Map<String, dynamic> json) {
    return MotivationalQuote(
      quote: json['quote'] as String,
      author: json['author'] as String,
      topic: json['topic'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'quote': quote,
        'author': author,
        'topic': topic,
      };
}
