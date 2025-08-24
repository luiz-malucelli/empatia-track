class DiaSalvo {
  final String date;
  final List<int> emotions;
  final String notes;

  DiaSalvo({
    required this.date,
    required this.emotions,
    required this.notes,
  }) : assert(emotions.length == 5, 'emotions list must have 5 values');

  @override
  String toString() {
    String truncatedNotes = notes.length > 30 ? '${notes.substring(0, 30)}...' : notes;

    return 'date: $date, emotions: $emotions, notes: $truncatedNotes';
  }

  // toJson method also remains unchanged.
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'emotions': emotions,
      'notes': notes,
    };
  }

  // Adjusted factory constructor to directly use the id from JSON.
  factory DiaSalvo.fromJson(Map<String, dynamic> json) {
    List<int> emotionsFromJson = List<int>.from(json['emotions']);

    // Ensure the emotions list always has 5 values
    if (emotionsFromJson.length != 5) {
      throw Exception('emotions list must have 5 values');
    }

    return DiaSalvo(
      date: json['date'],
      emotions: emotionsFromJson,
      notes: json['notes'],
    );
  }

}


