import 'package:flutter/material.dart';
import 'package:split_ease/theme/appBorders.dart';

class customTextField extends StatelessWidget {

	final String hintText;
	final bool obscureText;

	const customTextField({
		required this.hintText,
		this.obscureText = false,
		super.key
	});

	@override
	Widget build(BuildContext context) {
		return TextField(
			obscureText: obscureText,
            decoration: InputDecoration(
                hintText: hintText,
                filled: true,
                border: AppBorders.inputBorder,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                fillColor: Theme.of(context).colorScheme.onSecondary,
            ),
		);
	}

}