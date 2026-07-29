class Project {
  final int? id;
  final String name;
  final String? description;
  final String? status;
  final int? creatorId;
  final String? createTime;
  final String? updateTime;

  Project({
    this.id,
    required this.name,
    this.description,
    this.status,
    this.creatorId,
    this.createTime,
    this.updateTime,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      status: json['status'],
      creatorId: json['creatorId'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'description': description,
      'status': status,
    };
    data.removeWhere((k, v) => v == null);
    return data;
  }
}