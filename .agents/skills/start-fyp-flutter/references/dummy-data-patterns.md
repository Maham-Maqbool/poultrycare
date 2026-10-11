# Mock Data & Dummy State Design Patterns

In FYP frontend evaluations, judges and supervisors look for realistic workflows and rich interactions. Using generic "Lorem ipsum" or single-item lists damages the evaluation score. Use these patterns to make the frontend feel like a live, production app.

---

## 1. Domain-Authentic Dummy Records
Always tailor sample records to the exact domain described in `project-docs`.

- **Medical/Healthcare**: Realistic doctor names, medical specialties, appointment slots, vitals, medical history, clinical notes.
- **E-Commerce/Marketplace**: Detailed product titles, high-resolution Unsplash image URLs, currency tags, star ratings, review counts, discount percentages, stock status.
- **EdTech/Learning**: Course titles, instructor profiles, progress percentages (e.g., 68%), lecture counts, badges, certificates, quiz scores.
- **Fintech/Banking**: Transaction histories with positive/negative amounts, category icons, merchant names, dates, masked card numbers, account balances.
- **Smart City / IoT / Tracking**: Device statuses (Online/Offline), battery levels, GPS coordinates, telemetry graphs, timestamped logs.

---

## 2. In-Memory Mock Repository with Mutation Support
Allow the user to interact with the frontend dynamically:
- Searching filters the mock list in real-time.
- Tapping "Add to Favorites" or "Bookmark" toggles the state in memory.
- Submitting a "Create" or "Add" form inserts the new item into the mock repository and refreshes the list view.
- Submitting "Delete" removes the item from the mock list with an undo `SnackBar`.

```dart
class MockProductRepository {
  final List<ProductModel> _items = List.from(sampleProducts);

  Future<List<ProductModel>> getAll({String? query, String? category}) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Smooth loading sensation
    var filtered = _items;
    if (query != null && query.isNotEmpty) {
      filtered = filtered.where((p) => p.title.toLowerCase().contains(query.toLowerCase())).toList();
    }
    if (category != null && category != 'All') {
      filtered = filtered.where((p) => p.category == category).toList();
    }
    return filtered;
  }

  Future<ProductModel> toggleFavorite(String id) async {
    final index = _items.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updated = _items[index].copyWith(isFavorite: !_items[index].isFavorite);
      _items[index] = updated;
      return updated;
    }
    throw Exception('Item not found');
  }

  Future<void> addItem(ProductModel newItem) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _items.insert(0, newItem);
  }
}
```

---

## 3. High-Resolution Public Imagery
Use verified, reliable Unsplash CDN image URLs categorized by topic, or vector icons / SVGs, to prevent broken image icons:
- Avatars: `https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150` (diverse personas)
- Thumbnails: Use high quality URLs matching the domain.
- Fallback: Always provide an `errorBuilder` on `Image.network` showing an icon container if offline.
