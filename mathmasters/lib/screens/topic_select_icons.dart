import 'package:flutter/material.dart';
import '../models/question.dart';

IconData topicIcon(Topic t) => switch (t) {
  Topic.addition => Icons.add,
  Topic.subtraction => Icons.remove,
  Topic.multiplication => Icons.clear,
  Topic.division => Icons.percent,
  Topic.fractions => Icons.pie_chart,
  Topic.decimals => Icons.numbers,
};
