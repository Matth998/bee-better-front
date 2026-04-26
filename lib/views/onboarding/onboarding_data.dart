import 'package:intl/intl.dart';

class OnboardingData {
  DateTime? birthDate;
  String? gender;
  String? state;
  String? city;
  String? hasTdah;
  List<String> otherConditions;
  String? occupation;
  List<String> symptoms;

  OnboardingData({
    this.birthDate,
    this.gender,
    this.state,
    this.city,
    this.hasTdah,
    this.otherConditions = const [],
    this.occupation,
    this.symptoms = const [],
  });

  Map<String, dynamic> toJson() => {
    'birth_date': birthDate != null
        ? DateFormat('yyyy-MM-dd').format(birthDate!)
        : null,
    'gender': gender,
    'state': state,
    'city': city,
    'has_tdah': hasTdah,
    'other_conditions': otherConditions,
    'occupation': occupation,
    'symptoms': symptoms,
  };
}