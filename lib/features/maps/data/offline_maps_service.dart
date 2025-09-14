import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import '../domain/models/tile_region.dart';

class OfflineMapsService {
  static const _tileDbName = 'offline_maps.db';
  late Database _database;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$_tileDbName';

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE map_tiles (
            z INTEGER,
            x INTEGER,
            y INTEGER,
            tile BLOB,
            timestamp INTEGER,
            PRIMARY KEY (z, x, y)
          )
        ''');
        await db.execute('''
          CREATE TABLE regions (
            id TEXT PRIMARY KEY,
            name TEXT,
            min_lat REAL,
            max_lat REAL,
            min_lng REAL,
            max_lng REAL,
            min_zoom INTEGER,
            max_zoom INTEGER,
            timestamp INTEGER
          )
        ''');
      },
    );

    _isInitialized = true;
  }

  Future<void> downloadRegion(TileRegion region) async {
    await init();

    // Insert region metadata
    await _database.insert(
      'regions',
      {
        'id': region.id,
        'name': region.name,
        'min_lat': region.bounds.southwest.latitude,
        'max_lat': region.bounds.northeast.latitude,
        'min_lng': region.bounds.southwest.longitude,
        'max_lng': region.bounds.northeast.longitude,
        'min_zoom': region.minZoom,
        'max_zoom': region.maxZoom,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Calculate tile coordinates for the region
    final tiles = _calculateTiles(region);

    // Download tiles
    for (final tile in tiles) {
      try {
        final tileBytes = await _downloadTile(tile.z, tile.x, tile.y);
        await _database.insert(
          'map_tiles',
          {
            'z': tile.z,
            'x': tile.x,
            'y': tile.y,
            'tile': tileBytes,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        print('Failed to download tile: $e');
        // Continue with next tile
      }
    }
  }

  Future<List<TileRegion>> getDownloadedRegions() async {
    await init();

    final regions = await _database.query('regions');
    return regions.map((r) => TileRegion.fromMap(r)).toList();
  }

  Future<Uint8List?> getTile(int z, int x, int y) async {
    await init();

    final result = await _database.query(
      'map_tiles',
      columns: ['tile'],
      where: 'z = ? AND x = ? AND y = ?',
      whereArgs: [z, x, y],
    );

    if (result.isEmpty) return null;
    return result.first['tile'] as Uint8List;
  }

  Future<void> deleteRegion(String regionId) async {
    await init();

    final region = await _database.query(
      'regions',
      where: 'id = ?',
      whereArgs: [regionId],
    );

    if (region.isEmpty) return;

    await _database.delete(
      'map_tiles',
      where: '''
        z BETWEEN ? AND ? AND
        x BETWEEN ? AND ? AND
        y BETWEEN ? AND ?
      ''',
      whereArgs: [
        region[0]['min_zoom'],
        region[0]['max_zoom'],
        // Calculate tile coordinates from bounds
        _lon2tile(region[0]['min_lng'] as double, region[0]['min_zoom'] as int),
        _lon2tile(region[0]['max_lng'] as double, region[0]['min_zoom'] as int),
        _lat2tile(region[0]['max_lat'] as double, region[0]['min_zoom'] as int),
        _lat2tile(region[0]['min_lat'] as double, region[0]['min_zoom'] as int),
      ],
    );

    await _database.delete(
      'regions',
      where: 'id = ?',
      whereArgs: [regionId],
    );
  }

  Future<int> getRegionSize(String regionId) async {
    await init();

    final result = await _database.rawQuery('''
      SELECT COUNT(*) as count, SUM(LENGTH(tile)) as size
      FROM map_tiles
      WHERE z IN (
        SELECT DISTINCT z
        FROM map_tiles
        WHERE z BETWEEN (
          SELECT min_zoom FROM regions WHERE id = ?
        ) AND (
          SELECT max_zoom FROM regions WHERE id = ?
        )
      )
    ''', [regionId, regionId]);

    return (result.first['size'] as int?) ?? 0;
  }

  List<MapTile> _calculateTiles(TileRegion region) {
    final tiles = <MapTile>[];
    for (var z = region.minZoom; z <= region.maxZoom; z++) {
      final minX = _lon2tile(region.bounds.southwest.longitude, z);
      final maxX = _lon2tile(region.bounds.northeast.longitude, z);
      final minY = _lat2tile(region.bounds.northeast.latitude, z);
      final maxY = _lat2tile(region.bounds.southwest.latitude, z);

      for (var x = minX; x <= maxX; x++) {
        for (var y = minY; y <= maxY; y++) {
          tiles.add(MapTile(z: z, x: x, y: y));
        }
      }
    }
    return tiles;
  }

  Future<Uint8List> _downloadTile(int z, int x, int y) async {
    final url = 'https://tile.openstreetmap.org/$z/$x/$y.png';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to download tile');
    }
    return response.bodyBytes;
  }

  int _lon2tile(double lon, int z) {
    return ((lon + 180.0) / 360.0 * (1 << z)).floor();
  }

  int _lat2tile(double lat, int z) {
    final latRad = lat * pi / 180.0;
    return ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * (1 << z))
        .floor();
  }

  Future<void> close() async {
    if (_isInitialized) {
      await _database.close();
      _isInitialized = false;
    }
  }
}
