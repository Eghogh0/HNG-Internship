// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 1;

  @override
  Category read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Category.salary;
      case 1:
        return Category.food;
      case 2:
        return Category.transport;
      case 3:
        return Category.entertainment;
      case 4:
        return Category.shopping;
      case 5:
        return Category.bills;
      case 6:
        return Category.healthcare;
      case 7:
        return Category.education;
      case 8:
        return Category.other;
      default:
        return Category.salary;
    }
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    switch (obj) {
      case Category.salary:
        writer.writeByte(0);
        break;
      case Category.food:
        writer.writeByte(1);
        break;
      case Category.transport:
        writer.writeByte(2);
        break;
      case Category.entertainment:
        writer.writeByte(3);
        break;
      case Category.shopping:
        writer.writeByte(4);
        break;
      case Category.bills:
        writer.writeByte(5);
        break;
      case Category.healthcare:
        writer.writeByte(6);
        break;
      case Category.education:
        writer.writeByte(7);
        break;
      case Category.other:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
