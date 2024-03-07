import 'package:flutter/material.dart';

class Workbench extends StatefulWidget {
  const Workbench({super.key});

  @override
  WorkbenchState createState() => WorkbenchState();
}

class WorkbenchState extends State<Workbench> {
  List<String> availableSteps = [
    'Checkout Repo',
    'Setup SSH',
    'Setup & Cache Flutter',
    'Get Dependencies',
    'Dart Format',
    'Lint check',
    'Run Tests', // With coverage? Without coverage?
    'Build android app', // APK or AAB?
    'Upload android binary to firebase distribution',
    'Upload to playstore',
    'Build ios app',
    'Upload ios binary to firebase distribution',
    'Upload to applestore & testflight',
    'Notify via email',
    'Notify via slack',
  ];

  List<String> selectedSteps = [];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: availableSteps.length,
            itemBuilder: (context, index) {
              final step = availableSteps[index];
              return Draggable<String>(
                data: step,
                feedback: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width *
                        0.9, // Adjust the width as needed
                    minHeight:
                        50, // Minimum height for ListTile, adjust as needed
                  ),
                  child: Material(
                    // Wrapped in Material to ensure visual consistency in the feedback.
                    child: Card(
                      child: ListTile(
                        title: Text(step),
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Card(
                  child: ListTile(
                    title: Text(step),
                    iconColor: Colors.grey,
                  ),
                ),
                child: Card(
                  child: ListTile(
                    title: Text(step),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: DragTarget<String>(
            onAccept: (data) {
              setState(() {
                if (!selectedSteps.contains(data)) {
                  // Prevent adding duplicate steps
                  selectedSteps.add(data);
                }
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                color: Colors.grey[200],
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = selectedSteps.removeAt(oldIndex);
                      selectedSteps.insert(newIndex, item);
                    });
                  },
                  children: selectedSteps
                      .map((step) => ListTile(
                            key: ValueKey(step),
                            title: Text(step),
                            trailing: const Icon(Icons.menu),
                          ))
                      .toList(),
                ),
              );
            },
          ),
        ),
        Expanded(
          // Placeholder for the right column (Step settings)
          child: Container(
            color: Colors.grey[300],
            child: const Center(
              child: Text('Step Settings'),
            ),
          ),
        ),
      ],
    );
  }
}
