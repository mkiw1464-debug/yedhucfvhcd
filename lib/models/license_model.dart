class LicenseResponse {
  final bool valid;
  final String status;
  final DateTime? expiresAt;
  final String? hwid;

  LicenseResponse({
    required this.valid,
    required this.status,
    this.expiresAt,
    this.hwid,
  });

  factory LicenseResponse.fromJson(Map<String, dynamic> json) {
    return LicenseResponse(
      valid: json['valid'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      hwid: json['hwid'] as String?,
    );
  }

  bool get isActive => valid && status == 'active';

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  String get formattedExpiry {
    if (expiresAt == null) return '—';
    final d = expiresAt!;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
