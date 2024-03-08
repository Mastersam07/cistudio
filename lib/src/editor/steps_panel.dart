import 'package:flutter/material.dart';
import '../models/ci_step.dart';

class StepPanel extends StatelessWidget {
  final List<CIStep> availableSteps;

  const StepPanel({
    Key? key,
    required this.availableSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: availableSteps.length,
      itemBuilder: (context, index) {
        final step = availableSteps[index];
        return Draggable<CIStep>(
          data: step,
          feedback: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width *
                  0.9, // Adjust the width as needed
              minHeight: 50, // Minimum height for ListTile, adjust as needed
            ),
            child: Card(
              child: ListTile(
                title: Text(step.name),
              ),
            ),
          ),
          childWhenDragging: Card(
            child: ListTile(
              key: ValueKey(step.slug),
              title: Text(step.name),
              iconColor: Colors.grey,
            ),
          ),
          child: Card(
            child: ListTile(
              title: Text(step.name),
            ),
          ),
        );
      },
    );
  }
}
