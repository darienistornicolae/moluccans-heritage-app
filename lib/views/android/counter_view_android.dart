import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/counter_viewmodel.dart';

class CounterViewAndroid extends StatelessWidget {
  const CounterViewAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter (Android)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<CounterViewModel>(
              builder: (context, viewModel, child) {
                return Text(
                  '${viewModel.count}',
                  style: Theme.of(context).textTheme.displayLarge,
                );
              },
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    context.read<CounterViewModel>().decrement();
                  },
                  heroTag: 'decrement',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<CounterViewModel>().reset();
                  },
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: () {
                    context.read<CounterViewModel>().increment();
                  },
                  heroTag: 'increment',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

