import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.color,
    required this.icon,
    this.height,
    this.width,
  });

  final VoidCallback onTap;
  final String text;
  final Color color;
  final IconData icon;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final textExists = (text.isNotEmpty);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(15)),
      highlightColor: Colors.black,
      splashColor: Colors.transparent,
      child: Ink(
        width: width ?? 110,
        height: height ?? 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: color,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            textExists ? SizedBox(width: 5) : SizedBox(),
            Text(text, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
