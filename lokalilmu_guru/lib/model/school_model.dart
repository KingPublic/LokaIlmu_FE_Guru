class SchoolModel {
  final int idSekolah;
  final String npsn;
  final String namaSekolah;

  SchoolModel({
    required this.idSekolah,
    required this.npsn,
    required this.namaSekolah,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      idSekolah: json['id'] ?? json['idSekolah'] ?? 0,
      npsn: json['npsn']?.toString() ?? '',
      namaSekolah: json['nama'] ?? json['namaSekolah'] ?? '',
    );
  }
}