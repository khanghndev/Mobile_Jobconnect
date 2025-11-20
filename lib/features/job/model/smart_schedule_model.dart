import 'package:job_connect/features/job/model/job_posting_model.dart';

class SmartScheduleModel {
  final DateTime generatedAt;
  final String strategy;
  final List<Cluster> clusters;

  SmartScheduleModel({
    required this.generatedAt,
    required this.strategy,
    required this.clusters,
  });

  factory SmartScheduleModel.fromJson(Map<String, dynamic> json) {
    return SmartScheduleModel(
      generatedAt: DateTime.parse(json['generatedAt']),
      strategy: json['strategy'] ?? '',
      clusters: (json['clusters'] as List<dynamic>? ?? [])
          .map((e) => Cluster.fromJson(e))
          .toList(),
    );
  }
}

class Cluster {
  final String clusterId;
  final String label;
  final String description;
  final List<double> centroid;
  final List<ClusterJob> jobs;

  Cluster({
    required this.clusterId,
    required this.label,
    required this.description,
    required this.centroid,
    required this.jobs,
  });

  factory Cluster.fromJson(Map<String, dynamic> json) {
    return Cluster(
      clusterId: json['clusterId'] ?? '',
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      centroid: (json['centroid'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      jobs: (json['jobs'] as List<dynamic>? ?? [])
          .map((e) => ClusterJob.fromJson(e))
          .toList(),
    );
  }
}

class ClusterJob {
  final JobPostingModel job;
  final double skillScore;
  final double scheduleScore;
  final double geoScore;
  final double finalScore;
  final double? distanceKm; // có thể null
  final String scheduleSummary;

  ClusterJob({
    required this.job,
    required this.skillScore,
    required this.scheduleScore,
    required this.geoScore,
    required this.finalScore,
    this.distanceKm,
    required this.scheduleSummary,
  });

  factory ClusterJob.fromJson(Map<String, dynamic> json) {
    return ClusterJob(
      job: JobPostingModel.fromJson(json['job']),
      skillScore: (json['skillScore'] as num?)?.toDouble() ?? 0,
      scheduleScore: (json['scheduleScore'] as num?)?.toDouble() ?? 0,
      geoScore: (json['geoScore'] as num?)?.toDouble() ?? 0,
      finalScore: (json['finalScore'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      scheduleSummary: json['scheduleSummary'] ?? '',
    );
  }
}
