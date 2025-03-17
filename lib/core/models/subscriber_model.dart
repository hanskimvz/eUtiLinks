class SubscriberModel {
  final String subscriberId;
  final String? customerName;
  final String? customerNo;
  final String? subscriberNo;
  final String? meterId;
  final String? addrProv;
  final String? addrCity;
  final String? addrDist;
  final String? addrDetail;
  final String? addrApt;
  final String? addrDong;
  final String? addrRoad;
  final bool isActive;
  final String? phoneNumber;
  final String? email;
  final String? registrationDate;
  final String? contractType;
  final int? deviceCount;
  final String? lastPaymentDate;
  final String? memo;
  final bool? binded;
  final String? shareHouse;
  final String? category;
  final String? subscriberClass;
  final String? inOutdoor;
  final String? bindDeviceId;
  final String? bindDate;
  final int? no_;
  final String? flag;
  final String? lastCount;
  final String? lastAccess;

  SubscriberModel({
    required this.subscriberId,
    this.customerName,
    this.customerNo,
    this.subscriberNo,
    this.meterId,
    this.addrProv,
    this.addrCity,
    this.addrDist,
    this.addrDetail,
    this.addrApt,
    this.addrDong,
    this.addrRoad,
    required this.isActive,
    this.phoneNumber,
    this.email,
    this.registrationDate,
    this.contractType,
    this.deviceCount,
    this.lastPaymentDate,
    this.memo,
    this.binded,
    this.shareHouse,
    this.category,
    this.subscriberClass,
    this.inOutdoor,
    this.bindDeviceId,
    this.bindDate,
    this.no_,
    this.flag,
    this.lastCount,
    this.lastAccess,
  });

  factory SubscriberModel.fromJson(Map<String, dynamic> json) {
    bool? bindedValue;
    if (json['binded'] != null) {
      if (json['binded'] is bool) {
        bindedValue = json['binded'];
      } else if (json['binded'] is String) {
        bindedValue = json['binded'].toString().toLowerCase() == 'true';
      }
    }

    bool isActiveValue = true;
    if (json['is_active'] != null) {
      if (json['is_active'] is bool) {
        isActiveValue = json['is_active'];
      } else if (json['is_active'] is String) {
        isActiveValue = json['is_active'].toString().toLowerCase() == 'true';
      } else if (json['is_active'] is num) {
        isActiveValue = json['is_active'] != 0;
      }
    }

    int? deviceCountValue;
    if (json['device_count'] != null) {
      if (json['device_count'] is int) {
        deviceCountValue = json['device_count'];
      } else if (json['device_count'] is String) {
        try {
          deviceCountValue = int.parse(json['device_count']);
        } catch (e) {
          deviceCountValue = null;
        }
      }
    }
    
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

    return SubscriberModel(
      subscriberId: json['_id'] ?? json['subscriber_id'] ?? '',
      customerName: json['customer_name'],
      customerNo: json['customer_no'],
      subscriberNo: json['subscriber_no'],
      meterId: json['meter_id'],
      addrProv: json['addr_prov'],
      addrCity: json['addr_city'],
      addrDist: json['addr_dist'],
      addrDetail: json['addr_detail'],
      addrApt: json['addr_apt'],
      addrDong: json['addr_dong'],
      addrRoad: json['addr_road'],
      isActive: isActiveValue,
      phoneNumber: json['phone_number'],
      email: json['email'],
      registrationDate: json['registration_date'],
      contractType: json['contract_type'],
      deviceCount: deviceCountValue,
      lastPaymentDate: json['last_payment_date'],
      memo: json['memo'],
      binded: bindedValue,
      shareHouse: json['share_house'],
      category: json['category'],
      subscriberClass: json['class'],
      inOutdoor: json['in_outdoor'],
      bindDeviceId: json['bind_device_id'],
      bindDate: json['bind_date'],
      no_: noValue,
      flag: json['flag'],
      lastCount: json['last_count'],
      lastAccess: json['last_access'],
    );
  }
} 