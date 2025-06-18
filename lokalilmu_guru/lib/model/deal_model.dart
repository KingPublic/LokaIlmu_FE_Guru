// import 'package:flutter/material.dart';

// class DealModel {
//   final String id;
//   final String chatId;
//   final String fokusLatihan;
//   final int durasi;
//   final int sesiPertemuan;
//   final String metodeLatihan;
//   final String lokasiLatihan;
//   final DateTime tanggalMulai;
//   final DateTime tanggalSelesai;
//   final int jumlahPartisipan;
//   final double hargaPerSesi;
//   final String catatan;
//   final DealStatus status;
//   final DateTime createdAt;

//   DealModel({
//     required this.id,
//     required this.chatId,
//     required this.fokusLatihan,
//     required this.durasi,
//     required this.sesiPertemuan,
//     required this.metodeLatihan,
//     required this.lokasiLatihan,
//     required this.tanggalMulai,
//     required this.tanggalSelesai,
//     required this.jumlahPartisipan,
//     required this.hargaPerSesi,
//     required this.catatan,
//     required this.status,
//     required this.createdAt,
//   });

//   double get totalBiaya => hargaPerSesi * sesiPertemuan;

//   String get dealRequestId => 'DR${id.substring(0, 3).toUpperCase()}';

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'chatId': chatId,
//       'fokusLatihan': fokusLatihan,
//       'durasi': durasi,
//       'sesiPertemuan': sesiPertemuan,
//       'metodeLatihan': metodeLatihan,
//       'lokasiLatihan': lokasiLatihan,
//       'tanggalMulai': tanggalMulai.toIso8601String(),
//       'tanggalSelesai': tanggalSelesai.toIso8601String(),
//       'jumlahPartisipan': jumlahPartisipan,
//       'hargaPerSesi': hargaPerSesi,
//       'catatan': catatan,
//       'status': status.toString(),
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }

//   factory DealModel.fromJson(Map<String, dynamic> json) {
//     return DealModel(
//       id: json['id'],
//       chatId: json['chatId'],
//       fokusLatihan: json['fokusLatihan'],
//       durasi: json['durasi'],
//       sesiPertemuan: json['sesiPertemuan'],
//       metodeLatihan: json['metodeLatihan'],
//       lokasiLatihan: json['lokasiLatihan'],
//       tanggalMulai: DateTime.parse(json['tanggalMulai']),
//       tanggalSelesai: DateTime.parse(json['tanggalSelesai']),
//       jumlahPartisipan: json['jumlahPartisipan'],
//       hargaPerSesi: json['hargaPerSesi'].toDouble(),
//       catatan: json['catatan'],
//       status: DealStatus.values.firstWhere(
//         (e) => e.toString() == json['status'],
//       ),
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }
// }

// enum DealStatus {
//   menunggu,
//   diterima,
//   ditolak,
//   selesai,
// }

// extension DealStatusExtension on DealStatus {
//   String get displayName {
//     switch (this) {
//       case DealStatus.menunggu:
//         return 'Menunggu';
//       case DealStatus.diterima:
//         return 'Diterima';
//       case DealStatus.ditolak:
//         return 'Ditolak';
//       case DealStatus.selesai:
//         return 'Selesai';
//     }
//   }

//   Color get color {
//     switch (this) {
//       case DealStatus.menunggu:
//         return const Color(0xFFFF6B6B);
//       case DealStatus.diterima:
//         return const Color(0xFF4ECDC4);
//       case DealStatus.ditolak:
//         return const Color(0xFFFF6B6B);
//       case DealStatus.selesai:
//         return const Color(0xFF45B7D1);
//     }
//   }
// }
