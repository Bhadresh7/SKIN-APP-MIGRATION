class MetaModel {
  String? text;
  String? url;
  String? img;

  MetaModel({this.text, this.url, this.img});

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      text: json['text'] as String?,
      url: json['url'] as String?,
      img: json['img'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'url': url, 'img': img};
  }
}
