import '../models/media_item.dart';

enum MediaCategory {
  images,
  videos,
  presentations,
  all,
}

class MediaOrganizationService {
  final Map<String, List<String>> _tags = {};
  final Map<String, MediaCategory> _categories = {};

  void addTag(String mediaId, String tag) {
    _tags[mediaId] = _tags[mediaId] ?? [];
    if (!_tags[mediaId]!.contains(tag)) {
      _tags[mediaId]!.add(tag);
    }
  }

  void removeTag(String mediaId, String tag) {
    _tags[mediaId]?.remove(tag);
  }

  List<String> getTagsForMedia(String mediaId) {
    return _tags[mediaId] ?? [];
  }

  void setCategory(String mediaId, MediaCategory category) {
    _categories[mediaId] = category;
  }

  MediaCategory? getCategory(String mediaId) {
    return _categories[mediaId];
  }

  List<MediaItem> filterByCategory(
    List<MediaItem> items,
    MediaCategory category,
  ) {
    if (category == MediaCategory.all) return items;
    
    return items.where((item) {
      final itemCategory = _categories[item.id] ?? _getCategoryFromType(item.type);
      return itemCategory == category;
    }).toList();
  }

  List<MediaItem> filterByTag(List<MediaItem> items, String tag) {
    return items.where((item) {
      final itemTags = _tags[item.id] ?? [];
      return itemTags.contains(tag);
    }).toList();
  }

  List<MediaItem> filterByType(List<MediaItem> items, MediaType type) {
    return items.where((item) => item.type == type).toList();
  }

  List<MediaItem> searchMedia(
    List<MediaItem> items,
    String query,
  ) {
    final lowercaseQuery = query.toLowerCase();
    return items.where((item) {
      final titleMatch = item.title.toLowerCase().contains(lowercaseQuery);
      final tagMatch = (_tags[item.id] ?? [])
          .any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      return titleMatch || tagMatch;
    }).toList();
  }

  MediaCategory _getCategoryFromType(MediaType type) {
    switch (type) {
      case MediaType.image:
        return MediaCategory.images;
      case MediaType.video:
        return MediaCategory.videos;
      default:
        return MediaCategory.all;
    }
  }
}
