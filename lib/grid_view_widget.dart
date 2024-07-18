import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/metrics_notifiers/metrics_notifiers.dart';

class GridViewWidget extends StatelessWidget {
  const GridViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    return GridView.count(
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      crossAxisCount: 5,
      children: [
        const Spacer(),
        _GridViewItem(
          title: 'Bike',
          child: Column(
            children: [
              const _CustomDivider(),
              ValueListenableBuilder(
                valueListenable: BleBikeMetricsNotifier.instaCadence,
                builder: (context, value, child) => Text(
                  'Status: $value',
                  style: textStyle,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: BleBikeMetricsNotifier.instaCadence,
                builder: (context, value, child) => Text(
                  'Id: $value',
                  style: textStyle,
                ),
              ),
              const _CustomDivider(),
              ValueListenableBuilder(
                valueListenable: BleBikeMetricsNotifier.instaCadence,
                builder: (context, value, child) => Text(
                  'Cadencia: $value',
                  style: textStyle,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: BleBikeMetricsNotifier.instaPower,
                builder: (context, value, child) => Text(
                  'Potência: $value',
                  style: textStyle,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: BleBikeMetricsNotifier.resistanceLevel,
                builder: (context, value, child) => Text(
                  'Resistência: $value',
                  style: textStyle,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: BleBikeMetricsNotifier.speed,
                builder: (context, value, child) => Text(
                  'Velociadade: $value',
                  style: textStyle,
                ),
              ),
            ],
          ),
        ),
        _GridViewItem(
          title: 'Esteira',
          child: Column(
            children: [
              const _CustomDivider(),
              ValueListenableBuilder(
                valueListenable: BleBikeMetricsNotifier.instaCadence,
                builder: (context, value, child) => Text(
                  'Status: $value',
                  style: textStyle,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: BleBikeMetricsNotifier.instaCadence,
                builder: (context, value, child) => Text(
                  'Id: $value',
                  style: textStyle,
                ),
              ),
              const _CustomDivider(),
              ValueListenableBuilder(
                valueListenable: BleTreadmillMetricsNotifier.inclination,
                builder: (context, value, child) => Text(
                  'Inclinação: $value',
                  style: textStyle,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: BleTreadmillMetricsNotifier.instaPower,
                builder: (context, value, child) => Text(
                  'Potência: $value',
                  style: textStyle,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: BleTreadmillMetricsNotifier.speed,
                builder: (context, value, child) => Text(
                  'Velocidade: $value',
                  style: textStyle,
                ),
              ),
            ],
          ),
        ),
        _GridViewItem(
          title: 'MyBeat',
          child: Column(
            children: [
              const _CustomDivider(),
              ValueListenableBuilder(
                valueListenable: BleBikeMetricsNotifier.instaCadence,
                builder: (context, value, child) => Text(
                  'Status: $value',
                  style: textStyle,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: BleBikeMetricsNotifier.instaCadence,
                builder: (context, value, child) => Text(
                  'Id: $value',
                  style: textStyle,
                ),
              ),
              const _CustomDivider(),
              ValueListenableBuilder(
                valueListenable: BleFrequencyMeterMetricsNotifier.bpmValue,
                builder: (context, value, child) => Text(
                  'BPM: $value',
                  style: textStyle,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _GridViewItem extends StatelessWidget {
  final String title;
  final Widget child;
  const _GridViewItem({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(.1),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 50,
            ),
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Divider(
        height: 2,
      ),
    );
  }
}
