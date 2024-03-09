import 'package:flutter/material.dart';

import '../controller/export_controller.dart';
import '../models/ci_step.dart';

class ExportConfigPanel extends StatelessWidget {
  ExportConfigPanel({super.key, this.selectedSteps = const []});

  final List<CIStep> selectedSteps;
  final ExportController _exportController = ExportController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Export Configuration',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _exportController.exportGitHubActions(
                    context, selectedSteps),
                child: const Text('GitHub Actions'),
              ),
              ElevatedButton(
                onPressed: () =>
                    _exportController.exportGitLabCI(context, selectedSteps),
                child: const Text('GitLab CI'),
              ),
              ElevatedButton(
                onPressed: () =>
                    _exportController.exportAzureDevOps(context, selectedSteps),
                child: const Text('Azure DevOps'),
              ),
              ElevatedButton(
                onPressed: () => _exportController.exportBitbucketPipeline(
                    context, selectedSteps),
                child: const Text('Bitbucket Pipeline'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
