class Resume {
  String? key;
  String? photo;
  String name;
  String contact;
  String email;
  Map<String, dynamic> personalInfo;
  List<dynamic> languages;
  List<dynamic> skills;
  String objective;
  List<dynamic> experiences;
  List<dynamic> education;
  String reference;
  bool isFresher;
  int createdAt;


  Resume({
    this.key,
    this.photo,
    required this.name,
    required this.contact,
    required this.email,
    required this.personalInfo,
    required this.languages,
    required this.skills,
    required this.objective,
    required this.experiences,
    required this.education,
    required this.reference,
    required this.isFresher,
    required this.createdAt,
  });

  // factory Resume.fromMap(Map<dynamic, dynamic> map, String key) {
  //   return Resume(
  //     key: key,
  //     photo: map['photo'],
  //     name: map['name'] ?? '',
  //     contact: map['contact'] ?? '',
  //     email: map['email'] ?? '',
  //     personalInfo: Map<String, dynamic>.from(map['personalInfo'] ?? {}),
  //     languages: List<dynamic>.from(map['languages'] ?? []),
  //     skills: List<dynamic>.from(map['skills'] ?? []),
  //     objective: map['objective'] ?? '',
  //     experiences: List<dynamic>.from(map['experiences'] ?? []),
  //     education: List<dynamic>.from(map['education'] ?? []),
  //     reference: map['reference'] ?? '',
  //     isFresher: map['isFresher'] ?? false,
  //     createdAt: map['createdAt'] ?? 0,
  //   );
  // }
  factory Resume.fromMap(Map<dynamic, dynamic> map, String key) {
    return Resume(
      key: key,
      photo: map['photo'],
      name: map['name'] ?? '',
      contact: map['contact'] ?? '',
      email: map['email'] ?? '',
      personalInfo: Map<String, dynamic>.from(
        (map['personalInfo'] as Map).map(
              (key, value) => MapEntry(key.toString(), value),
        ),
      ),
      languages: List<dynamic>.from(map['languages'] ?? []),
      skills: List<dynamic>.from(map['skills'] ?? []),
      objective: map['objective'] ?? '',
      experiences: List<dynamic>.from(
        (map['experiences'] ?? []).map((e) => Map<String, dynamic>.from(
          (e as Map).map((key, value) => MapEntry(key.toString(), value)),
        )),
      ),
      education: List<dynamic>.from(
        (map['education'] ?? []).map((e) => Map<String, dynamic>.from(
          (e as Map).map((key, value) => MapEntry(key.toString(), value)),
        )),
      ),
      reference: map['reference'] ?? '',
      isFresher: map['isFresher'] ?? false,
      createdAt: map['createdAt'] ?? 0,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'photo': photo,
      'name': name,
      'contact': contact,
      'email': email,
      'personalInfo': personalInfo,
      'languages': languages,
      'skills': skills,
      'objective': objective,
      'experiences': experiences,
      'education': education,
      'reference': reference,
      'isFresher': isFresher,
      'createdAt': createdAt,
    };
  }
}