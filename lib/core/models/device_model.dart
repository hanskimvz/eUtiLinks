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

    return DeviceModel(
      deviceUid: json['device_uid'] ?? '',
      lastCount: json['last_count'] is int ? json['last_count'] : null,
      lastAccess: json['last_access'],
      flag: flagValue,
      uptime: json['uptime'] is int ? json['uptime'] : null,
      initialAccess: json['initial_access'],
      refInterval: json['ref_interval'] is int ? json['ref_interval'] : null,
      minimum: json['minimum'] is int ? json['minimum'] : null,
      maximum: json['maximum'] is int ? json['maximum'] : null,
      battery: json['battery'] is int ? json['battery'] : null,
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
    );
  }
} 