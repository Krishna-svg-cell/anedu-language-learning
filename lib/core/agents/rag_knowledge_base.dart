class RAGKnowledgeItem {
  final String category;
  final String topic;
  final String content;
  final List<String> keywords;
  final Map<String, String> languageBridges; // e.g. {"Telugu": "Neellu -> Neeru", "Tamil": "Thanneer -> Neeru"}

  RAGKnowledgeItem({
    required this.category,
    required this.topic,
    required this.content,
    required this.keywords,
    this.languageBridges = const {},
  });
}

class RAGKnowledgeBase {
  static final List<RAGKnowledgeItem> items = [
    // Greetings & Etiquette
    RAGKnowledgeItem(
      category: 'greetings',
      topic: 'Formal vs Casual Greetings',
      content: 'Use "Namaskara" for hello. Add respect with "banni" (come) or "kuthkoli" (sit). With elders, add the suffix "-ri" to verbs, e.g. "Hogabanni" (please go and return) instead of "Hogu" (go).',
      keywords: ['hello', 'namaskara', 'respect', 'elder', 'polite'],
      languageBridges: {
        'Telugu': 'Namaskaramu in Telugu is Namaskara in Kannada. Suffix "-ri" is similar to Telugu "-andi" (e.g., cheppandi -> heli).',
        'Tamil': 'Vanakkam in Tamil is Namaskara in Kannada. Suffix "-ri" is similar to Tamil "-nga" (e.g., sollunga -> heli).',
        'Hindi': 'Namaste in Hindi is Namaskara in Kannada. Suffix "-ri" is similar to Hindi "-ji" (e.g., aaiye -> banni).',
      },
    ),
    // Transport & Directions
    RAGKnowledgeItem(
      category: 'travel',
      topic: 'Hailing an Auto & Directions',
      content: 'To ask "Will you come to [Place]?", say "[Place]-ge barthira?". To ask for fare, say "Eshtu aaguthe?" (How much will it be?) or "Meter haaki" (put the meter). Directions: "Nera hogi" (go straight), "Edake thirugi" (turn left), "Balake thirugi" (turn right), "Illi nilli" (stop here).',
      keywords: ['auto', 'fare', 'price', 'left', 'right', 'straight', 'stop', 'directions'],
      languageBridges: {
        'Telugu': 'Nera hogi (straight) is similar to Telugu "Nera vellandi". Edake (left) is similar to Telugu "Yadama". Balake (right) is similar to "Kudi".',
        'Tamil': 'Nera hogi (straight) is similar to Tamil "Nera ponga". Edake (left) is similar to Tamil "Idathu". Balake (right) is similar to "Valathu".',
        'Hindi': 'Nera hogi (straight) matches Hindi "Seedhe jao". Edake (left) is similar to "Baayein". Balake (right) is similar to "Daayein".',
      },
    ),
    // Restaurant & Dining
    RAGKnowledgeItem(
      category: 'restaurant',
      topic: 'Ordering Food',
      content: 'In Darshinis, order by saying "[Item] kodi" (Give [Item]). E.g. "Ondu filter kapi kodi" (Give one filter coffee). To say no sugar, say "Sakkare beda". Ask for water: "Neeru kodi". Ask for bill: "Bill kodi". Ask if it is fresh: "Fresh idya?".',
      keywords: ['coffee', 'order', 'fresh', 'water', 'sugar', 'no sugar', 'darshini', 'idli', 'dosa'],
      languageBridges: {
        'Telugu': 'Kodi (give) is similar to Telugu "Ivandi". Beda (no / don\'t want) matches Telugu "Vaddu". Neeru (water) is similar to Telugu "Neellu".',
        'Tamil': 'Kodi (give) matches Tamil "Kudunga". Beda (don\'t want) matches Tamil "Vendaam". Neeru (water) matches Tamil "Neer".',
        'Hindi': 'Kodi (give) is like Hindi "Do". Beda (don\'t want) matches Hindi "Nahi chahiye". Neeru (water) is similar to Hindi "Neer / Paani".',
      },
    ),
    // Shopping & Money
    RAGKnowledgeItem(
      category: 'shopping',
      topic: 'Asking for Prices and UPI Pay',
      content: 'To ask price, say "Eshtu?" (How much?) or "Idhu eshtu?" (How much is this?). Payment: "Scan mado QR code yelli ide?" (Where is the QR code to scan?). "PhonePe idya?" or "GPay idya?". "Change illa" (No change).',
      keywords: ['upi', 'scan', 'pay', 'change', 'price', 'cost', 'how much'],
      languageBridges: {
        'Telugu': 'Eshtu (how much) is similar to Telugu "Entha". Yelli ide (where is it) matches Telugu "Yekkada undi".',
        'Tamil': 'Eshtu (how much) is similar to Tamil "Evvalo". Yelli ide (where is it) matches Tamil "Enga iruku".',
        'Hindi': 'Eshtu (how much) matches Hindi "Kitna". Yelli ide (where is it) matches Hindi "Kahaan hai".',
      },
    ),
    // College & Classes
    RAGKnowledgeItem(
      category: 'college',
      topic: 'Academic Conversations',
      content: 'Where is the library? -> "Library yelli ide?". When is the exam? -> "Exam yaavaga?". Book -> "Pustaka". Friend -> "Snehitha" (male) or "Snehithe" (female), though colloquially "Friend" is very common. Roommate is "Roommate".',
      keywords: ['class', 'library', 'exam', 'book', 'roommate', 'college', 'professor'],
      languageBridges: {
        'Telugu': 'Pustaka (book) matches Telugu "Pustakamu". Yaavaga (when) matches Telugu "Eppudu".',
        'Tamil': 'Pustaka (book) matches Tamil "Pusthagam". Snehitha (friend) is similar to Tamil "Snegidhan".',
        'Hindi': 'Pustaka (book) matches Hindi "Pustak". Yaavaga (when) is similar to Hindi "Kab".',
      },
    ),
  ];

  static List<RAGKnowledgeItem> query(String text) {
    final queryText = text.toLowerCase();
    final List<RAGKnowledgeItem> results = [];
    for (final item in items) {
      if (item.category.contains(queryText) ||
          item.topic.toLowerCase().contains(queryText) ||
          item.content.toLowerCase().contains(queryText) ||
          item.keywords.any((k) => queryText.contains(k) || k.contains(queryText))) {
        results.add(item);
      }
    }
    return results.isNotEmpty ? results : [items[0]]; // fallback
  }

  static String getLanguageBridgeAdvice(String nativeLang, String category) {
    final match = items.firstWhere(
      (item) => item.category == category,
      orElse: () => items[0],
    );
    return match.languageBridges[nativeLang] ?? '';
  }
}
