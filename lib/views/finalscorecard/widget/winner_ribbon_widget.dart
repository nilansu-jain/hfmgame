import 'package:flutter/material.dart';

class WinnerRibbonWidget extends StatelessWidget {
  final String ribbonImage;
  final String name;
  final String? profileImage; // asset or network
  final int score;
  final double topMargin;

  const WinnerRibbonWidget({
    super.key,
    required this.ribbonImage,
    required this.name,
    required this.score,
    this.profileImage,
    this.topMargin = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 6),

          Stack(
            alignment: Alignment.topCenter,
            children: [
              /// Ribbon Image
              Image.asset(
                ribbonImage,
                height: 160,
              ),

              /// Circular Profile Image
              Positioned(
                top: 8,
                child:
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 27,
                    backgroundImage: profileImage != null
                        ? AssetImage(profileImage!)
                        : null,
                    child: profileImage == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                ),
              ),

              /// Score Below Circle
              Positioned(
                top: 100,
                child: Text(
                  score.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
