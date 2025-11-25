import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/chart_data.dart';
import '../models/chart_interaction.dart';

/// Helper class for detecting chart interactions
class ChartInteractionHelper {
  /// Find nearest point to tap location
  static ChartInteractionResult? findNearestPoint(
    Offset tapPosition,
    List<ChartDataSet> dataSets,
    Size chartSize,
    double minX,
    double maxX,
    double minY,
    double maxY,
    double tapRadius,
  ) {
    double minDistance = double.infinity;
    ChartInteractionResult? nearestResult;

    for (int dsIndex = 0; dsIndex < dataSets.length; dsIndex++) {
      final dataSet = dataSets[dsIndex];
      
      for (int ptIndex = 0; ptIndex < dataSet.dataPoints.length; ptIndex++) {
        final point = dataSet.dataPoints[ptIndex];
        
        // Convert to canvas coordinates
        final xRange = maxX - minX;
        final yRange = maxY - minY;
        if (xRange == 0 || yRange == 0) continue;
        
        final canvasX = ((point.x - minX) / xRange) * chartSize.width;
        final canvasY = chartSize.height - ((point.y - minY) / yRange) * chartSize.height;
        final canvasPoint = Offset(canvasX, canvasY);
        
        // Calculate distance
        final distance = (tapPosition - canvasPoint).distance;
        
        if (distance < tapRadius && distance < minDistance) {
          minDistance = distance;
          nearestResult = ChartInteractionResult(
            point: point,
            datasetIndex: dsIndex,
            elementIndex: ptIndex,
            isHit: true,
          );
        }
      }
    }

    return nearestResult;
  }

  /// Find bar at tap location
  static ChartInteractionResult? findBar(
    Offset tapPosition,
    List<ChartDataSet> dataSets,
    Size chartSize,
    double minX,
    double maxX,
    double minY,
    double maxY,
    double barWidth,
  ) {
    final xRange = maxX - minX;
    if (xRange == 0) return null;

    for (int dsIndex = 0; dsIndex < dataSets.length; dsIndex++) {
      final dataSet = dataSets[dsIndex];
      
      for (int barIndex = 0; barIndex < dataSet.dataPoints.length; barIndex++) {
        final point = dataSet.dataPoints[barIndex];
        
        // Calculate bar position
        final canvasX = ((point.x - minX) / xRange) * chartSize.width;
        final barHeight = (point.y / maxY) * chartSize.height;
        final barY = chartSize.height - barHeight;
        
        // Check if tap is within bar bounds
        final barLeft = canvasX - barWidth / 2;
        final barRight = canvasX + barWidth / 2;
        final barTop = barY;
        final barBottom = chartSize.height;
        
        if (tapPosition.dx >= barLeft &&
            tapPosition.dx <= barRight &&
            tapPosition.dy >= barTop &&
            tapPosition.dy <= barBottom) {
          return ChartInteractionResult(
            point: point,
            datasetIndex: dsIndex,
            elementIndex: barIndex,
            isHit: true,
          );
        }
      }
    }

    return null;
  }

  /// Find pie segment at tap location
  static ChartInteractionResult? findPieSegment(
    Offset tapPosition,
    List<PieData> data,
    Size size,
    double centerSpaceRadius,
  ) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    // Check if tap is within chart bounds
    final distanceFromCenter = (tapPosition - center).distance;
    if (distanceFromCenter < centerSpaceRadius || distanceFromCenter > radius) {
      return null;
    }

    final total = data.map((d) => d.value).reduce((a, b) => a + b);
    double startAngle = -math.pi / 2;
    
    // Calculate angle from center to tap point
    final dx = tapPosition.dx - center.dx;
    final dy = tapPosition.dy - center.dy;
    final tapAngle = math.atan2(dy, dx);
    // Normalize to 0-2π range starting from top
    final normalizedAngle = (tapAngle + math.pi / 2 + 2 * math.pi) % (2 * math.pi);

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final sweepAngle = (item.value / total) * 2 * math.pi;
      final endAngle = startAngle + sweepAngle;
      
      // Normalize start and end angles
      final normalizedStart = (startAngle + 2 * math.pi) % (2 * math.pi);
      final normalizedEnd = (endAngle + 2 * math.pi) % (2 * math.pi);
      
      // Check if tap angle is within segment
      bool isInSegment = false;
      if (normalizedEnd > normalizedStart) {
        isInSegment = normalizedAngle >= normalizedStart && normalizedAngle <= normalizedEnd;
      } else {
        // Segment wraps around
        isInSegment = normalizedAngle >= normalizedStart || normalizedAngle <= normalizedEnd;
      }
      
      if (isInSegment) {
        return ChartInteractionResult(
          segment: item,
          elementIndex: i,
          isHit: true,
        );
      }
      
      startAngle = endAngle;
    }

    return null;
  }
}

