// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 6;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String,
      tripId: fields[1] as String,
      title: fields[7] as String,
      amount: fields[2] as double,
      currency: fields[3] as String,
      category: fields[4] as ExpenseCategory,
      date: fields[5] as DateTime,
      payerId: fields[8] as String,
      splitWithIds: (fields[9] as List).cast<String>(),
      note: fields[6] as String?,
      subCategory: fields[10] as ExpenseSubCategory?,
      merchant: fields[11] as String?,
      geolocation: fields[12] as String?,
      receiptIds: (fields[13] as List?)?.cast<String>(),
      tags: (fields[14] as List?)?.cast<String>(),
      metadata: (fields[15] as Map?)?.cast<String, dynamic>(),
      isRecurring: fields[16] as bool,
      recurringPattern: fields[17] as String?,
      recurringEndDate: fields[18] as DateTime?,
      taxAmount: fields[19] as double?,
      tipAmount: fields[20] as double?,
      paymentMethod: fields[21] as PaymentMethod?,
      voiceNoteId: fields[22] as String?,
      description: fields[23] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tripId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.title)
      ..writeByte(8)
      ..write(obj.payerId)
      ..writeByte(9)
      ..write(obj.splitWithIds)
      ..writeByte(10)
      ..write(obj.subCategory)
      ..writeByte(11)
      ..write(obj.merchant)
      ..writeByte(12)
      ..write(obj.geolocation)
      ..writeByte(13)
      ..write(obj.receiptIds)
      ..writeByte(14)
      ..write(obj.tags)
      ..writeByte(15)
      ..write(obj.metadata)
      ..writeByte(16)
      ..write(obj.isRecurring)
      ..writeByte(17)
      ..write(obj.recurringPattern)
      ..writeByte(18)
      ..write(obj.recurringEndDate)
      ..writeByte(19)
      ..write(obj.taxAmount)
      ..writeByte(20)
      ..write(obj.tipAmount)
      ..writeByte(21)
      ..write(obj.paymentMethod)
      ..writeByte(22)
      ..write(obj.voiceNoteId)
      ..writeByte(23)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 26;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.food;
      case 1:
        return ExpenseCategory.transport;
      case 2:
        return ExpenseCategory.accommodation;
      case 3:
        return ExpenseCategory.entertainment;
      case 4:
        return ExpenseCategory.shopping;
      case 5:
        return ExpenseCategory.healthcare;
      case 6:
        return ExpenseCategory.education;
      case 7:
        return ExpenseCategory.business;
      case 8:
        return ExpenseCategory.utilities;
      case 9:
        return ExpenseCategory.insurance;
      case 10:
        return ExpenseCategory.communication;
      case 11:
        return ExpenseCategory.emergencies;
      case 12:
        return ExpenseCategory.gifts;
      case 13:
        return ExpenseCategory.fees;
      case 14:
        return ExpenseCategory.custom;
      case 15:
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.food;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.food:
        writer.writeByte(0);
        break;
      case ExpenseCategory.transport:
        writer.writeByte(1);
        break;
      case ExpenseCategory.accommodation:
        writer.writeByte(2);
        break;
      case ExpenseCategory.entertainment:
        writer.writeByte(3);
        break;
      case ExpenseCategory.shopping:
        writer.writeByte(4);
        break;
      case ExpenseCategory.healthcare:
        writer.writeByte(5);
        break;
      case ExpenseCategory.education:
        writer.writeByte(6);
        break;
      case ExpenseCategory.business:
        writer.writeByte(7);
        break;
      case ExpenseCategory.utilities:
        writer.writeByte(8);
        break;
      case ExpenseCategory.insurance:
        writer.writeByte(9);
        break;
      case ExpenseCategory.communication:
        writer.writeByte(10);
        break;
      case ExpenseCategory.emergencies:
        writer.writeByte(11);
        break;
      case ExpenseCategory.gifts:
        writer.writeByte(12);
        break;
      case ExpenseCategory.fees:
        writer.writeByte(13);
        break;
      case ExpenseCategory.custom:
        writer.writeByte(14);
        break;
      case ExpenseCategory.other:
        writer.writeByte(15);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseSubCategoryAdapter extends TypeAdapter<ExpenseSubCategory> {
  @override
  final int typeId = 35;

  @override
  ExpenseSubCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseSubCategory.breakfast;
      case 1:
        return ExpenseSubCategory.lunch;
      case 2:
        return ExpenseSubCategory.dinner;
      case 3:
        return ExpenseSubCategory.snacks;
      case 4:
        return ExpenseSubCategory.drinks;
      case 5:
        return ExpenseSubCategory.groceries;
      case 6:
        return ExpenseSubCategory.fastFood;
      case 7:
        return ExpenseSubCategory.fineDining;
      case 8:
        return ExpenseSubCategory.flights;
      case 9:
        return ExpenseSubCategory.trains;
      case 10:
        return ExpenseSubCategory.buses;
      case 11:
        return ExpenseSubCategory.taxis;
      case 12:
        return ExpenseSubCategory.rideshare;
      case 13:
        return ExpenseSubCategory.carRental;
      case 14:
        return ExpenseSubCategory.fuel;
      case 15:
        return ExpenseSubCategory.parking;
      case 16:
        return ExpenseSubCategory.tolls;
      case 17:
        return ExpenseSubCategory.hotels;
      case 18:
        return ExpenseSubCategory.hostels;
      case 19:
        return ExpenseSubCategory.airbnb;
      case 20:
        return ExpenseSubCategory.camping;
      case 21:
        return ExpenseSubCategory.resorts;
      case 22:
        return ExpenseSubCategory.movies;
      case 23:
        return ExpenseSubCategory.concerts;
      case 24:
        return ExpenseSubCategory.sports;
      case 25:
        return ExpenseSubCategory.nightlife;
      case 26:
        return ExpenseSubCategory.tours;
      case 27:
        return ExpenseSubCategory.activities;
      case 28:
        return ExpenseSubCategory.museums;
      case 29:
        return ExpenseSubCategory.amusementParks;
      case 30:
        return ExpenseSubCategory.clothing;
      case 31:
        return ExpenseSubCategory.electronics;
      case 32:
        return ExpenseSubCategory.souvenirs;
      case 33:
        return ExpenseSubCategory.books;
      case 34:
        return ExpenseSubCategory.personalCare;
      case 35:
        return ExpenseSubCategory.pharmacy;
      case 36:
        return ExpenseSubCategory.doctorVisit;
      case 37:
        return ExpenseSubCategory.hospital;
      case 38:
        return ExpenseSubCategory.dental;
      case 39:
        return ExpenseSubCategory.emergency;
      case 40:
        return ExpenseSubCategory.meetings;
      case 41:
        return ExpenseSubCategory.supplies;
      case 42:
        return ExpenseSubCategory.networking;
      case 43:
        return ExpenseSubCategory.conferences;
      case 44:
        return ExpenseSubCategory.none;
      case 45:
        return ExpenseSubCategory.customSubCategory;
      default:
        return ExpenseSubCategory.breakfast;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseSubCategory obj) {
    switch (obj) {
      case ExpenseSubCategory.breakfast:
        writer.writeByte(0);
        break;
      case ExpenseSubCategory.lunch:
        writer.writeByte(1);
        break;
      case ExpenseSubCategory.dinner:
        writer.writeByte(2);
        break;
      case ExpenseSubCategory.snacks:
        writer.writeByte(3);
        break;
      case ExpenseSubCategory.drinks:
        writer.writeByte(4);
        break;
      case ExpenseSubCategory.groceries:
        writer.writeByte(5);
        break;
      case ExpenseSubCategory.fastFood:
        writer.writeByte(6);
        break;
      case ExpenseSubCategory.fineDining:
        writer.writeByte(7);
        break;
      case ExpenseSubCategory.flights:
        writer.writeByte(8);
        break;
      case ExpenseSubCategory.trains:
        writer.writeByte(9);
        break;
      case ExpenseSubCategory.buses:
        writer.writeByte(10);
        break;
      case ExpenseSubCategory.taxis:
        writer.writeByte(11);
        break;
      case ExpenseSubCategory.rideshare:
        writer.writeByte(12);
        break;
      case ExpenseSubCategory.carRental:
        writer.writeByte(13);
        break;
      case ExpenseSubCategory.fuel:
        writer.writeByte(14);
        break;
      case ExpenseSubCategory.parking:
        writer.writeByte(15);
        break;
      case ExpenseSubCategory.tolls:
        writer.writeByte(16);
        break;
      case ExpenseSubCategory.hotels:
        writer.writeByte(17);
        break;
      case ExpenseSubCategory.hostels:
        writer.writeByte(18);
        break;
      case ExpenseSubCategory.airbnb:
        writer.writeByte(19);
        break;
      case ExpenseSubCategory.camping:
        writer.writeByte(20);
        break;
      case ExpenseSubCategory.resorts:
        writer.writeByte(21);
        break;
      case ExpenseSubCategory.movies:
        writer.writeByte(22);
        break;
      case ExpenseSubCategory.concerts:
        writer.writeByte(23);
        break;
      case ExpenseSubCategory.sports:
        writer.writeByte(24);
        break;
      case ExpenseSubCategory.nightlife:
        writer.writeByte(25);
        break;
      case ExpenseSubCategory.tours:
        writer.writeByte(26);
        break;
      case ExpenseSubCategory.activities:
        writer.writeByte(27);
        break;
      case ExpenseSubCategory.museums:
        writer.writeByte(28);
        break;
      case ExpenseSubCategory.amusementParks:
        writer.writeByte(29);
        break;
      case ExpenseSubCategory.clothing:
        writer.writeByte(30);
        break;
      case ExpenseSubCategory.electronics:
        writer.writeByte(31);
        break;
      case ExpenseSubCategory.souvenirs:
        writer.writeByte(32);
        break;
      case ExpenseSubCategory.books:
        writer.writeByte(33);
        break;
      case ExpenseSubCategory.personalCare:
        writer.writeByte(34);
        break;
      case ExpenseSubCategory.pharmacy:
        writer.writeByte(35);
        break;
      case ExpenseSubCategory.doctorVisit:
        writer.writeByte(36);
        break;
      case ExpenseSubCategory.hospital:
        writer.writeByte(37);
        break;
      case ExpenseSubCategory.dental:
        writer.writeByte(38);
        break;
      case ExpenseSubCategory.emergency:
        writer.writeByte(39);
        break;
      case ExpenseSubCategory.meetings:
        writer.writeByte(40);
        break;
      case ExpenseSubCategory.supplies:
        writer.writeByte(41);
        break;
      case ExpenseSubCategory.networking:
        writer.writeByte(42);
        break;
      case ExpenseSubCategory.conferences:
        writer.writeByte(43);
        break;
      case ExpenseSubCategory.none:
        writer.writeByte(44);
        break;
      case ExpenseSubCategory.customSubCategory:
        writer.writeByte(45);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseSubCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 38;

  @override
  PaymentMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethod.cash;
      case 1:
        return PaymentMethod.creditCard;
      case 2:
        return PaymentMethod.debitCard;
      case 3:
        return PaymentMethod.digitalWallet;
      case 4:
        return PaymentMethod.bankTransfer;
      case 5:
        return PaymentMethod.other;
      default:
        return PaymentMethod.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    switch (obj) {
      case PaymentMethod.cash:
        writer.writeByte(0);
        break;
      case PaymentMethod.creditCard:
        writer.writeByte(1);
        break;
      case PaymentMethod.debitCard:
        writer.writeByte(2);
        break;
      case PaymentMethod.digitalWallet:
        writer.writeByte(3);
        break;
      case PaymentMethod.bankTransfer:
        writer.writeByte(4);
        break;
      case PaymentMethod.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
