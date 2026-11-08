import '../models/flock_model.dart';

/// mockFlocksData provides realistic poultry flocks representing
/// different sheds, breeds, and flock sizes on a farm.
final List<FlockModel> mockFlocksData = [
  FlockModel(
    id: 'flock-101',
    userId: 'usr-001',
    name: 'Shed 1: Broilers (Batch 26)',
    birdCount: 500,
    breed: 'Cobb 500 Broiler',
    notes: 'Day 24 of cycle. Vaccinated for ND on Day 7. Litter turned yesterday.',
    createdAt: DateTime.now().subtract(const Duration(days: 24)),
    activeDiseaseCount: 1,
  ),
  FlockModel(
    id: 'flock-102',
    userId: 'usr-001',
    name: 'Shed 2: Commercial Layers',
    birdCount: 320,
    breed: 'Lohmann Brown',
    notes: 'Egg production stable at 88%. Water electrolytes added.',
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    activeDiseaseCount: 0,
  ),
  FlockModel(
    id: 'flock-103',
    userId: 'usr-001',
    name: 'Pen 3: Desi Native Birds',
    birdCount: 85,
    breed: 'Aseel / Desi Cross',
    notes: 'Semi-free range pen. Monitored for external parasites.',
    createdAt: DateTime.now().subtract(const Duration(days: 12)),
    activeDiseaseCount: 0,
  ),
  FlockModel(
    id: 'flock-104',
    userId: 'usr-001',
    name: 'Isolation Bay: Quarantined',
    birdCount: 14,
    breed: 'Mixed Broilers',
    notes: 'Birds separated following mucoid fecal detection.',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    activeDiseaseCount: 2,
  ),
];
