class MealPlan {
  final List<DayPlan> days;
  
  MealPlan({
    required this.days,
  });
  
  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      days: List<DayPlan>.from(json['days'].map((x) => DayPlan.fromJson(x))),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'days': days.map((x) => x.toJson()).toList(),
    };
  }
}

class DayPlan {
  final String name;
  final String breakfast;
  final String lunch;
  final String dinner;
  
  DayPlan({
    required this.name,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });
  
  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      name: json['name'],
      breakfast: json['breakfast'],
      lunch: json['lunch'],
      dinner: json['dinner'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
    };
  }
}
