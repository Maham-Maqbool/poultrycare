import '../models/user_model.dart';

/// mockUsersData provides authentic commercial demonstration profiles
/// for rural farmers and extension veterinarians.
final List<UserModel> mockUsersData = [
  UserModel(
    id: 'usr-001',
    displayName: 'My Poultry Farm [Demo]',
    email: 'farmer@poultrycare.farm',
    phone: null,
    role: 'farmer',
    locale: 'ur',
    consentToRetainImages: true,
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
    lastSeenAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  UserModel(
    id: 'usr-002',
    displayName: 'Veterinary Clinic [Demo]',
    email: 'vet.support@poultrycare.farm',
    phone: null,
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
