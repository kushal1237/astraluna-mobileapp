import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../providers/app_state.dart';

class LocationPickerDialog extends StatelessWidget {
  final AppState appState;

  const LocationPickerDialog({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAstro = appState.isAstroRedMode;

    return AlertDialog(
      backgroundColor: theme.cardTheme.color,
      title: Row(
        children: [
          Icon(
            Icons.location_on,
            color: isAstro ? Colors.redAccent : theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Select Your Location'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: LocationService.presetCities.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final city = LocationService.presetCities[index];
            final isSelected = city.cityName == appState.currentLocation.cityName;

            return ListTile(
              leading: Text(city.flagEmoji, style: const TextStyle(fontSize: 24)),
              title: Text(
                '${city.cityName}, ${city.country}',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? (isAstro ? Colors.redAccent : theme.colorScheme.primary)
                      : null,
                ),
              ),
              subtitle: Text('Lat: ${city.latitude}°, Lon: ${city.longitude}°'),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: isAstro ? Colors.redAccent : theme.colorScheme.primary,
                    )
                  : null,
              onTap: () {
                appState.setCityLocation(city);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Location updated to ${city.cityName}, ${city.country}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
