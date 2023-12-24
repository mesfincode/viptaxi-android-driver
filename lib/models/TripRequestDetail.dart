class TripRequestDetail {
  String? riderName;
  String? riderPhone;
  String? riderPickUpAddress;
  String? riderDestinatinoAddress;
  String? pickUpTime;
  String? status;
  String? dateSent;
  TripRequestDetail({
     this.riderName,
     this.riderPhone,
     this.riderPickUpAddress,
     this.riderDestinatinoAddress,
     this.pickUpTime,
     this.status,
     this.dateSent,

  });

    factory TripRequestDetail.fromJson(Map<String, dynamic> json) {
    return TripRequestDetail(
      riderName: json['riderName'],
      riderPhone: json['riderPhone'],
      riderPickUpAddress: json['riderPickUpAddress'],
      riderDestinatinoAddress: json['riderDestinatinoAddress'],
      pickUpTime: json['pickUpTime'],
      status: json['status'],
      dateSent: json['dateSent'],
      // createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['riderName'] = this.riderName;
    data['riderPhone'] = this.riderPhone;
    data['riderPickUpAddress'] = this.riderPickUpAddress;
    data['riderDestinatinoAddress'] = this.riderDestinatinoAddress;
    data['pickUpTime'] = this.pickUpTime;
    data['status'] = this.status;
    data['dateSent'] = this.dateSent;
    return data;
  }
}
