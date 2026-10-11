import '../models/user_model.dart';

/// mockUsersData provides authentic demonstration profiles
/// for rural farmers and extension veterinarians.
final List<UserModel> mockUsersData = [
  UserModel(
    id: 'usr-001',
    displayName: 'Maham Maqbool',
    email: 'maham.maqbool@poultrycare.farm',
    phone: '+92 300 1234567',
    role: 'farmer',
    locale: 'en',
    consentToRetainImages: true,
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
    lastSeenAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  UserModel(
    id: 'usr-002',
    displayName: 'Dr. Shahzad Hussain',
    email: 'dr.shahzad@kfueit.edu.pk',
    phone: '+92 321 7654321',
    role: 'admin',
    locale: 'en',
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
    locale: 'en',
    consentToRetainImages: false,
    createdAt: DateTime.now(),
    lastSeenAt: DateTime.now(),
  ),
];
