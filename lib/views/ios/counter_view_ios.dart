import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/counter_viewmodel.dart';

class CounterViewIOS extends StatelessWidget {
  const CounterViewIOS({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Counter (iOS)'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Consumer<CounterViewModel>(
                builder: (context, viewModel, child) {
                  return Text(
                    '${viewModel.count}',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    onPressed: () {
                      context.read<CounterViewModel>().decrement();
                    },
                    child: const Icon(CupertinoIcons.minus),
                  ),
                  const SizedBox(width: 20),
                  CupertinoButton(
                    onPressed: () {
                      context.read<CounterViewModel>().reset();
                    },
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 20),
                  CupertinoButton(
                    onPressed: () {
                      context.read<CounterViewModel>().increment();
                    },
                    child: const Icon(CupertinoIcons.plus),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

