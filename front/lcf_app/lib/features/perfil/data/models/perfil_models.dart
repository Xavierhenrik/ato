class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.plan,
    required this.academicPhase,
    required this.dailyStudyMins,
    required this.nivelamentoPendente,
  });

  final String id;
  final String name;
  final String email;
  final String plan;
  final String academicPhase;
  final int dailyStudyMins;
  final bool nivelamentoPendente;

  bool get isPro => plan == 'pro';

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        plan: json['plan'] as String? ?? 'free',
        academicPhase: json['academicPhase'] as String? ?? '',
        dailyStudyMins: json['dailyStudyMins'] as int? ?? 30,
        nivelamentoPendente: json['nivelamentoPendente'] as bool? ?? false,
      );
}
