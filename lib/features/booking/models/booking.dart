import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'booking.g.dart';

@HiveType(typeId: 20) // Moved to enum range to avoid conflicts
enum BookingType {
  @HiveField(0)
  flight,
  @HiveField(1)
  hotel,
  @HiveField(2)
  car,
  @HiveField(3)
  activity
}

@HiveType(typeId: 21) // Sequential enum ID
enum BookingStatus {
  @HiveField(0)
  reserved,
  @HiveField(1)
  cancelled,
  @HiveField(2)
  completed
}

// Flight-specific details
@HiveType(typeId: 28) // Updated to avoid conflicts
class FlightDetails extends HiveObject {
  @HiveField(0)
  final String flightNumber;

  @HiveField(1)
  final String airline;

  @HiveField(2)
  final String origin;

  @HiveField(3)
  final String destination;

  @HiveField(4)
  final DateTime departureTime;

  @HiveField(5)
  final DateTime arrivalTime;

  @HiveField(6)
  final String? terminal;

  @HiveField(7)
  final String? gate;

  @HiveField(8)
  final String? seat;

  @HiveField(9)
  final String? bookingReference;

  @HiveField(10)
  final String? checkInUrl;

  FlightDetails({
    required this.flightNumber,
    required this.airline,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    this.terminal,
    this.gate,
    this.seat,
    this.bookingReference,
    this.checkInUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'flightNumber': flightNumber,
      'airline': airline,
      'origin': origin,
      'destination': destination,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      if (terminal != null) 'terminal': terminal,
      if (gate != null) 'gate': gate,
      if (seat != null) 'seat': seat,
      if (bookingReference != null) 'bookingReference': bookingReference,
      if (checkInUrl != null) 'checkInUrl': checkInUrl,
    };
  }

  factory FlightDetails.fromJson(Map<String, dynamic> json) {
    return FlightDetails(
      flightNumber: json['flightNumber'] as String,
      airline: json['airline'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      terminal: json['terminal'] as String?,
      gate: json['gate'] as String?,
      seat: json['seat'] as String?,
      bookingReference: json['bookingReference'] as String?,
      checkInUrl: json['checkInUrl'] as String?,
    );
  }
}

// Hotel-specific details
@HiveType(typeId: 29)
class HotelDetails extends HiveObject {
  @HiveField(0)
  final String hotelName;

  @HiveField(1)
  final String address;

  @HiveField(2)
  final DateTime checkIn;

  @HiveField(3)
  final DateTime checkOut;

  @HiveField(4)
  final String roomType;

  @HiveField(5)
  final int guests;

  @HiveField(6)
  final String? confirmationNumber;

  @HiveField(7)
  final String? contactPhone;

  @HiveField(8)
  final List<String>? amenities;

  @HiveField(9)
  final bool breakfastIncluded;

  @HiveField(10)
  final String? specialRequests;

  HotelDetails({
    required this.hotelName,
    required this.address,
    required this.checkIn,
    required this.checkOut,
    required this.roomType,
    required this.guests,
    this.confirmationNumber,
    this.contactPhone,
    this.amenities,
    this.breakfastIncluded = false,
    this.specialRequests,
  });

  Map<String, dynamic> toJson() {
    return {
      'hotelName': hotelName,
      'address': address,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'roomType': roomType,
      'guests': guests,
      if (confirmationNumber != null) 'confirmationNumber': confirmationNumber,
      if (contactPhone != null) 'contactPhone': contactPhone,
      if (amenities != null) 'amenities': amenities,
      'breakfastIncluded': breakfastIncluded,
      if (specialRequests != null) 'specialRequests': specialRequests,
    };
  }

  factory HotelDetails.fromJson(Map<String, dynamic> json) {
    return HotelDetails(
      hotelName: json['hotelName'] as String,
      address: json['address'] as String,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      roomType: json['roomType'] as String,
      guests: json['guests'] as int,
      confirmationNumber: json['confirmationNumber'] as String?,
      contactPhone: json['contactPhone'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)?.cast<String>(),
      breakfastIncluded: json['breakfastIncluded'] ?? false,
      specialRequests: json['specialRequests'] as String?,
    );
  }
}

// Transportation-specific details
@HiveType(typeId: 30)
class TransportationDetails extends HiveObject {
  @HiveField(0)
  final String vehicleType;

  @HiveField(1)
  final String pickupLocation;

  @HiveField(2)
  final String dropoffLocation;

  @HiveField(3)
  final DateTime pickupTime;

  @HiveField(4)
  final DateTime? expectedArrival;

  @HiveField(5)
  final String? driverName;

  @HiveField(6)
  final String? driverPhone;

  @HiveField(7)
  final String? vehiclePlate;

  @HiveField(8)
  final String? bookingReference;

  @HiveField(9)
  final String transportType; // taxi, train, bus, etc.

  @HiveField(10)
  final String? trainNumber;

  @HiveField(11)
  final String? platformNumber;

  @HiveField(12)
  final String? seatNumber;

  TransportationDetails({
    required this.vehicleType,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupTime,
    required this.transportType,
    this.expectedArrival,
    this.driverName,
    this.driverPhone,
    this.vehiclePlate,
    this.bookingReference,
    this.trainNumber,
    this.platformNumber,
    this.seatNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleType': vehicleType,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'pickupTime': pickupTime.toIso8601String(),
      'transportType': transportType,
      if (expectedArrival != null)
        'expectedArrival': expectedArrival!.toIso8601String(),
      if (driverName != null) 'driverName': driverName,
      if (driverPhone != null) 'driverPhone': driverPhone,
      if (vehiclePlate != null) 'vehiclePlate': vehiclePlate,
      if (bookingReference != null) 'bookingReference': bookingReference,
      if (trainNumber != null) 'trainNumber': trainNumber,
      if (platformNumber != null) 'platformNumber': platformNumber,
      if (seatNumber != null) 'seatNumber': seatNumber,
    };
  }

  factory TransportationDetails.fromJson(Map<String, dynamic> json) {
    return TransportationDetails(
      vehicleType: json['vehicleType'] as String,
      pickupLocation: json['pickupLocation'] as String,
      dropoffLocation: json['dropoffLocation'] as String,
      pickupTime: DateTime.parse(json['pickupTime'] as String),
      transportType: json['transportType'] as String,
      expectedArrival: json['expectedArrival'] != null
          ? DateTime.parse(json['expectedArrival'] as String)
          : null,
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      vehiclePlate: json['vehiclePlate'] as String?,
      bookingReference: json['bookingReference'] as String?,
      trainNumber: json['trainNumber'] as String?,
      platformNumber: json['platformNumber'] as String?,
      seatNumber: json['seatNumber'] as String?,
    );
  }
}

@HiveType(typeId: 15) // Feature models range 10-19
class Booking extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final BookingType type;

  @HiveField(2)
  final String provider;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final Map<String, dynamic> details; // Keep for backward compatibility

  @HiveField(5)
  final double price;

  @HiveField(6)
  final String currencyCode;

  @HiveField(7)
  final DateTime date;

  @HiveField(8)
  final String tripId;

  @HiveField(9)
  BookingStatus status;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final FlightDetails? flightDetails;

  @HiveField(12)
  final HotelDetails? hotelDetails;

  @HiveField(13)
  final TransportationDetails? transportationDetails;

  Booking({
    String? id,
    required this.type,
    required this.provider,
    required this.title,
    required this.details,
    required this.price,
    required this.currencyCode,
    required this.date,
    required this.tripId,
    this.status = BookingStatus.reserved,
    DateTime? createdAt,
    this.flightDetails,
    this.hotelDetails,
    this.transportationDetails,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Convenience getters for typed details
  FlightDetails? get flight => flightDetails;
  HotelDetails? get hotel => hotelDetails;
  TransportationDetails? get transportation => transportationDetails;

  // Factory constructors for specific booking types
  factory Booking.flight({
    String? id,
    required String provider,
    required String title,
    required double price,
    required String currencyCode,
    required DateTime date,
    required String tripId,
    required FlightDetails flightDetails,
    BookingStatus status = BookingStatus.reserved,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id,
      type: BookingType.flight,
      provider: provider,
      title: title,
      details: flightDetails.toJson(),
      price: price,
      currencyCode: currencyCode,
      date: date,
      tripId: tripId,
      status: status,
      createdAt: createdAt,
      flightDetails: flightDetails,
    );
  }

  factory Booking.hotel({
    String? id,
    required String provider,
    required String title,
    required double price,
    required String currencyCode,
    required DateTime date,
    required String tripId,
    required HotelDetails hotelDetails,
    BookingStatus status = BookingStatus.reserved,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id,
      type: BookingType.hotel,
      provider: provider,
      title: title,
      details: hotelDetails.toJson(),
      price: price,
      currencyCode: currencyCode,
      date: date,
      tripId: tripId,
      status: status,
      createdAt: createdAt,
      hotelDetails: hotelDetails,
    );
  }

  factory Booking.transportation({
    String? id,
    required String provider,
    required String title,
    required double price,
    required String currencyCode,
    required DateTime date,
    required String tripId,
    required TransportationDetails transportationDetails,
    BookingStatus status = BookingStatus.reserved,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id,
      type: BookingType.car,
      provider: provider,
      title: title,
      details: transportationDetails.toJson(),
      price: price,
      currencyCode: currencyCode,
      date: date,
      tripId: tripId,
      status: status,
      createdAt: createdAt,
      transportationDetails: transportationDetails,
    );
  }

  Booking copyWith({
    String? id,
    BookingType? type,
    String? provider,
    String? title,
    Map<String, dynamic>? details,
    double? price,
    String? currencyCode,
    DateTime? date,
    String? tripId,
    BookingStatus? status,
    DateTime? createdAt,
    FlightDetails? flightDetails,
    HotelDetails? hotelDetails,
    TransportationDetails? transportationDetails,
  }) {
    return Booking(
      id: id ?? this.id,
      type: type ?? this.type,
      provider: provider ?? this.provider,
      title: title ?? this.title,
      details: details ?? Map<String, dynamic>.from(this.details),
      price: price ?? this.price,
      currencyCode: currencyCode ?? this.currencyCode,
      date: date ?? this.date,
      tripId: tripId ?? this.tripId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      flightDetails: flightDetails ?? this.flightDetails,
      hotelDetails: hotelDetails ?? this.hotelDetails,
      transportationDetails:
          transportationDetails ?? this.transportationDetails,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Booking && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'provider': provider,
      'title': title,
      'details': details,
      'price': price,
      'currencyCode': currencyCode,
      'date': date.toIso8601String(),
      'tripId': tripId,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      if (flightDetails != null) 'flightDetails': flightDetails!.toJson(),
      if (hotelDetails != null) 'hotelDetails': hotelDetails!.toJson(),
      if (transportationDetails != null)
        'transportationDetails': transportationDetails!.toJson(),
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      type: BookingType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      provider: json['provider'] as String,
      title: json['title'] as String,
      details: json['details'] as Map<String, dynamic>,
      price: json['price'] as double,
      currencyCode: json['currencyCode'] as String,
      date: DateTime.parse(json['date'] as String),
      tripId: json['tripId'] as String,
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      flightDetails: json['flightDetails'] != null
          ? FlightDetails.fromJson(
              json['flightDetails'] as Map<String, dynamic>)
          : null,
      hotelDetails: json['hotelDetails'] != null
          ? HotelDetails.fromJson(json['hotelDetails'] as Map<String, dynamic>)
          : null,
      transportationDetails: json['transportationDetails'] != null
          ? TransportationDetails.fromJson(
              json['transportationDetails'] as Map<String, dynamic>)
          : null,
    );
  }
}
