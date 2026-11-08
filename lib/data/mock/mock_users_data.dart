import '../models/user_model.dart';

/// mockUsersData provides authentic commercial demonstration profiles
/// for rural farmers and extension veterinarians.
final List<UserModel> mockUsersData = [
  UserModel(
    id: 'usr-001',
    displayName: 'Chaudhry Poultry Farms',
    email: 'farmer@poultrycare.farm',
    phone: '+92 300 1234567',
    role: 'farmer',
    locale: 'ur',
    consentToRetainImages: true,
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
    lastSeenAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  UserModel(
    id: 'usr-002',
    displayName: 'Dr. Tariq Veterinary Clinic',
    email: 'vet.support@poultrycare.farm',
    phone: '+92 321 7654321',
    role: 'admin',
    locale: 'ur',
    consentToRetainImages: true,
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
    lastSeenAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  UserModel(
    id: 'usr-003',
    displayName: 'Guest Farmer',
    email: null,
    phone: null,
    role: 'farmer',
    locale: 'ur',
    consentToRetainImages: false,
    createdAt: DateTime.now(),
    lastSeenAt: DateTime.now(),
  ),
];
