import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,

        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return const Color(0xFF216BFF).withValues(alpha: 0.5);
            }

            if (states.contains(WidgetState.pressed)) {
              return const Color(0xFF174FCC);
            }

            return const Color(0xFF216BFF);
          }),

          foregroundColor: WidgetStateProperty.all(Colors.white),

          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.pressed)) {
              return 1;
            }

            return 0;
          }),

          overlayColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.10),
          ),

          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
        ),

        child: loading
            ? const SizedBox(
                height: 21,
                width: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  if (icon != null) ...[
                    const SizedBox(width: 7),
                    Icon(icon, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}
