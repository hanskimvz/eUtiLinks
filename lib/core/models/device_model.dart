class DeviceModel {
  final String deviceUid;
  final int? lastCount;
  final String? lastAccess;
  final String? flag;
  final int? uptime;
  final String? initialAccess;
  final int? refInterval;
  final int? minimum;
  final int? maximum;
  final int? battery;
  final String? customerName;
  final String? customerNo;
  final String? addrProv;
  final String? addrCity;
  final String? addrDist;
  final String? addrDong;
  final String? addrDetail;
  final bool? shareHouse;
  final String? addrApt;
  final String? category;
  final String? subscriberNo;
  final String? meterId;
  final String? deviceClass;
  final String? inOutdoor;
  final String? releaseDate;
  final String? installerId;
  final int? no_;
  final String? comment;
  final int? initialCount;
  final String? installDate;
  final String? serverIp;
  final int? serverPort;
  final int? lastTimestamp;
  final String? outdoor;

  DeviceModel({
    required this.deviceUid,
    this.lastCount,
    this.lastAccess,
    required this.flag,
    this.uptime,
    this.initialAccess,
    this.refInterval,
    this.minimum,
    this.maximum,
    this.battery,
    this.customerName,
    this.customerNo,
    this.addrProv,
    this.addrCity,
    this.addrDist,
    this.addrDong,
    this.addrDetail,
    this.shareHouse,
    this.addrApt,
    this.category,
    this.subscriberNo,
    this.meterId,
    this.deviceClass,
    this.inOutdoor,
    this.releaseDate,
    this.installerId,
    this.no_,
    this.comment,
    this.initialCount,
    this.installDate,
    this.serverIp,
    this.serverPort,
    this.lastTimestamp,
    this.outdoor,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    int? noValue;
    if (json['no_'] != null) {
      if (json['no_'] is int) {
        noValue = json['no_'];
      } else if (json['no_'] is String) {
        try {
          noValue = int.parse(json['no_']);
        } catch (e) {
          noValue = null;
        }
      }
    }
    
    String? flagValue;
    if (json['flag'] != null) {
      if (json['flag'] is String) {
        flagValue = json['flag'];
      } else if (json['flag'] is bool) {
        flagValue = json['flag'] ? 'active' : 'inactive';
      } else {
        flagValue = json['flag'].toString();
      }
    }

    int? parseIntValue(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return DeviceModel(
      deviceUid: json['device_uid'] ?? '',
      lastCount: parseIntValue(json['last_count']),
      lastAccess: json['last_access'],
      flag: flagValue,
      uptime: parseIntValue(json['uptime']),
      initialAccess: json['initial_access'],
      refInterval: parseIntValue(json['ref_interval']),
      minimum: parseIntValue(json['minimum']),
      maximum: parseIntValue(json['maximum']),
      battery: parseIntValue(json['battery']),
      customerName: json['customer_name'],
      customerNo: json['customer_no'],
      addrProv: json['addr_prov'],
      addrCity: json['addr_city'],
      addrDist: json['addr_dist'],
      addrDong: json['addr_dong'],
      addrDetail: json['addr_detail'],
      shareHouse: json['share_house'],
      addrApt: json['addr_apt'],
      category: json['category'],
      subscriberNo: json['subscriber_no'],
      meterId: json['meter_id'],
      deviceClass: json['class'],
      inOutdoor: json['in_outdoor'],
      releaseDate: json['release_date'],
      installerId: json['installer_id'],
      no_: noValue,
      comment: json['comment'],
      initialCount: parseIntValue(json['initial_count']),
      installDate: json['install_date'],
      serverIp: json['server_ip'],
      serverPort: parseIntValue(json['server_port']),
      lastTimestamp: parseIntValue(json['last_timestamp']),
      outdoor: json['outdoor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_uid': deviceUid,
      'last_count': lastCount,
      'last_access': lastAccess,
      'flag': flag,
      'uptime': uptime,
      'initial_access': initialAccess,
      'ref_interval': refInterval,
      'minimum': minimum,
      'maximum': maximum,
      'battery': battery,
      'customer_name': customerName,
      'customer_no': customerNo,
      'addr_prov': addrProv,
      'addr_city': addrCity,
      'addr_dist': addrDist,
      'addr_dong': addrDong,
      'addr_detail': addrDetail,
      'share_house': shareHouse,
      'addr_apt': addrApt,
      'category': category,
      'subscriber_no': subscriberNo,
      'meter_id': meterId,
      'class': deviceClass,
      'in_outdoor': inOutdoor,
      'release_date': releaseDate,
      'installer_id': installerId,
      'no_': no_,
      'comment': comment,
      'initial_count': initialCount,
      'install_date': installDate,
      'server_ip': serverIp,
      'server_port': serverPort,
      'last_timestamp': lastTimestamp,
      'outdoor': outdoor,
    };
  }
} 