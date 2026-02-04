import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 40,
              vertical: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderShimmer(),
                SizedBox(height: 40),

                _buildInfoBoxShimmer(),
                SizedBox(height: 40),

                _buildSectionShimmer(),
                SizedBox(height: 40),

                _buildSectionShimmer(),
                SizedBox(height: 50),

                _buildActionButtonsShimmer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShimmerBox(height: 52, width: 52),
        SizedBox(height: 24),
        _ShimmerBox(height: 40, width: double.infinity),
        SizedBox(height: 12),
        _ShimmerBox(height: 20, width: 200),
      ],
    );
  }

  Widget _buildInfoBoxShimmer() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ShimmerBox(height: 24, width: 24),
              SizedBox(width: 12),
              _ShimmerBox(height: 24, width: 150),
            ],
          ),
          SizedBox(height: 12),
          _ShimmerBox(height: 60, width: double.infinity),
        ],
      ),
    );
  }

  Widget _buildSectionShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShimmerBox(height: 24, width: 180),
        SizedBox(height: 12),
        _ShimmerBox(height: 56, width: double.infinity),
      ],
    );
  }

  Widget _buildActionButtonsShimmer() {
    return Column(
      children: [
        _ShimmerBox(height: 56, width: double.infinity),
        SizedBox(height: 12),
        _ShimmerBox(height: 56, width: double.infinity),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double width;

  const _ShimmerBox({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
