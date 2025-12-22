class Venue {
  final String id;
  final String name;
  final String blockName;
  final String imageUrl; // For block/building
  final String destinationUrl; // For specific room/venue photo
  final List<String> instructions;

  const Venue({
    required this.id,
    required this.name,
    required this.blockName,
    required this.imageUrl,
    required this.destinationUrl,
    required this.instructions,
  });
}
